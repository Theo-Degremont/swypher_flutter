import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/services/headphone_service.dart';
import 'package:swypher_flutter/shared/widgets/modals/headphone_modal.dart';

class RecordMusicController extends GetxController {
  late final MainController mainController;
  late final AudioService _audio;
  late final HeadphoneService _headphones;

  // ─── Fichiers ────────────────────────────────────────────────────────────────
  final Rx<PlatformFile?> toplineFile   = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> recordedVoice = Rx<PlatformFile?>(null);

  // ─── État ────────────────────────────────────────────────────────────────────
  /// true = micro actif, données qui s'enregistrent.
  final isRecording   = false.obs;

  /// true = lecture de prévisualisation en cours.
  final isPlayingBack = false.obs;

  /// Durée totale enregistrée (s'accumule entre pauses, réinitialisé sur delete).
  final recordingElapsed = Duration.zero.obs;

  /// Barres du visualiseur — persistantes entre pauses.
  final bars = RxList<double>([]);

  // ─── Internes ─────────────────────────────────────────────────────────────────
  late final AudioRecorder _recorder;
  StreamSubscription<Amplitude>? _amplitudeSub;
  StreamSubscription<void>?      _voiceCompleteSub;
  Timer?                         _recordingTimer;

  /// Chemin du fichier AAC en cours d'enregistrement (session unique).
  String? _currentRecordingPath;

  bool _playbackStarted = false;

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
    _audio         = Get.find<AudioService>();
    _headphones    = Get.find<HeadphoneService>();
    _recorder      = AudioRecorder();
  }

  @override
  void onReady() {
    super.onReady();
    HeadphoneModal.show();
    _headphones.refresh();
  }

  // ─── Topline ──────────────────────────────────────────────────────────────────

  Future<void> pickToplineFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac', 'webm'],
    );
    if (result == null) return;

    toplineFile.value = result.files.single;
    final path = result.files.single.path;
    if (path != null) await _audio.preload(AudioType.topline, path);
  }

  Future<void> removeToplineFile() async {
    await _audio.stop(AudioType.topline);
    await _audio.stop(AudioType.record);
    toplineFile.value = null;
    _playbackStarted  = false;
  }

  // ─── Durée max ────────────────────────────────────────────────────────────────

  Duration get _maxRecordingDuration {
    if (toplineFile.value != null) {
      final d = _audio.durationRx(AudioType.topline).value;
      if (d > Duration.zero) return d;
    }
    return const Duration(minutes: 5);
  }

  // ─── Toggle principal du micro ────────────────────────────────────────────────

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await _finalizeRecording();
      return;
    }

    // Vérifie la présence d'écouteurs avant de lancer l'enregistrement.
    await _headphones.refresh();
    if (!_headphones.isHeadphoneConnected.value) {
      HeadphoneModal.show();
      return;
    }

    await _startRecording();
  }

  // ─── Démarrage ───────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    // Coupe la lecture de prévisualisation.
    await _audio.stop(AudioType.voice);
    await _audio.stop(AudioType.topline);
    isPlayingBack.value = false;
    _playbackStarted    = false;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _showError('Autorisez l\'accès au microphone pour enregistrer.');
      return;
    }

    // Rafraîchit l'état des écouteurs juste avant de démarrer.
    await _headphones.refresh();

    // Tente de sélectionner le micro intégré du téléphone en priorité,
    // même si des écouteurs avec micro sont connectés.
    final builtInMic = await _headphones.findBuiltInMic();

    _currentRecordingPath =
        '${Directory.systemTemp.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      RecordConfig(
        encoder:     AudioEncoder.aacLc,
        bitRate:     128000,
        sampleRate:  44100,
        numChannels: 1,
        // Si un micro intégré est trouvé, on l'utilise explicitement.
        // Null = le package utilise le défaut du système.
        device: builtInMic,
      ),
      path: _currentRecordingPath!,
    );

    // Topline de référence pendant la prise — uniquement si écouteurs connectés.
    // Sans écouteurs, la topline n'est pas jouée pour éviter tout bleeding.
    final toplinePath = toplineFile.value?.path;
    if (toplinePath != null && _headphones.isHeadphoneConnected.value) {
      await _audio.play(AudioType.record, toplinePath);
    }

    _startAmplitudeSubscription();
    _startTimer();
    isRecording.value = true;
  }

  // ─── Finalisation (stop réel → fichier prêt) ──────────────────────────────────

  Future<void> _finalizeRecording() async {
    _stopTimer();
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;

    final path = await _recorder.stop();
    isRecording.value = false;

    await _audio.stop(AudioType.record);

    if (path != null) {
      final file = File(path);
      recordedVoice.value = PlatformFile(
        path: path,
        name: 'voice_record.m4a',
        size: await file.length(),
      );
      _playbackStarted = false;
    }
  }

  // ─── Suppression ─────────────────────────────────────────────────────────────

  Future<void> deleteRecording() async {
    _stopTimer();
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;

    // Si le recorder tourne encore, on le stoppe proprement.
    if (isRecording.value) await _recorder.stop();

    _voiceCompleteSub?.cancel();
    _voiceCompleteSub = null;

    await _audio.stop(AudioType.voice);
    await _audio.stop(AudioType.topline);
    await _audio.stop(AudioType.record);

    isRecording.value      = false;
    isPlayingBack.value    = false;
    _playbackStarted       = false;
    _currentRecordingPath  = null;
    recordedVoice.value    = null;
    recordingElapsed.value = Duration.zero;
    bars.clear();
  }

  // ─── Lecture prévisualisation ─────────────────────────────────────────────────

  Future<void> togglePlayback() async {
    if (isPlayingBack.value) {
      await _audio.pause(AudioType.voice);
      if (toplineFile.value != null) await _audio.pause(AudioType.topline);
      isPlayingBack.value = false;
    } else {
      if (!_playbackStarted) {
        await _startPlayback();
      } else {
        await _audio.resume(AudioType.voice);
        if (toplineFile.value?.path != null) await _audio.resume(AudioType.topline);
        isPlayingBack.value = true;
      }
    }
  }

  Future<void> restartPlayback() async {
    _voiceCompleteSub?.cancel();
    _voiceCompleteSub = null;
    await _audio.stop(AudioType.voice);
    if (toplineFile.value != null) await _audio.stop(AudioType.topline);
    _playbackStarted    = false;
    isPlayingBack.value = false;
    await _startPlayback();
  }

  Future<void> _startPlayback() async {
    final voicePath = recordedVoice.value?.path;
    if (voicePath == null) return;

    await _audio.play(AudioType.voice, voicePath);
    if (toplineFile.value?.path != null) {
      // Toujours à plein volume pendant l'écoute, indépendamment de l'état
      // des écouteurs (le ducking ne s'applique qu'à AudioType.record
      // pendant l'enregistrement).
      await _audio.play(AudioType.topline, toplineFile.value!.path!, volume: 1.0);
    }

    _playbackStarted    = true;
    isPlayingBack.value = true;

    _voiceCompleteSub?.cancel();
    _voiceCompleteSub = _audio.onComplete(AudioType.voice).listen((_) async {
      await _audio.stop(AudioType.topline);
      isPlayingBack.value = false;
      _playbackStarted    = false;
    });
  }

  // ─── Accesseurs réactifs ──────────────────────────────────────────────────────

  Rx<Duration> get voicePosition => _audio.positionRx(AudioType.voice);
  Rx<Duration> get voiceDuration  => _audio.durationRx(AudioType.voice);

  // ─── Navigation ───────────────────────────────────────────────────────────────

  Future<void> goToCompleteMusic() async {
    Get.toNamed(
      Routes.COMPLETE_MUSIC,
      arguments: {
        'toplineFile': toplineFile.value,
        'voiceFile':   recordedVoice.value,
      },
    );
  }

  // ─── Helpers internes ────────────────────────────────────────────────────────

  void _startAmplitudeSubscription() {
    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 80))
        .listen((amp) {
      final normalized = ((amp.current + 60) / 60).clamp(0.0, 1.0);
      bars.add(normalized);
      if (bars.length > 500) bars.removeAt(0);
    });
  }

  void _startTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      recordingElapsed.value += const Duration(seconds: 1);
      if (recordingElapsed.value >= _maxRecordingDuration) _finalizeRecording();
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _showError(String message) {
    Get.snackbar(
      'Erreur',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.backgroundColor,
      colorText: AppColors.primaryTextColor,
      borderColor: AppColors.primaryColor.withValues(alpha: 0.4),
      borderWidth: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void onClose() async {
    _stopTimer();
    await _voiceCompleteSub?.cancel();
    await _amplitudeSub?.cancel();
    await _recorder.dispose();
    super.onClose();
  }
}
