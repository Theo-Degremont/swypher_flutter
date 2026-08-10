import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';

class RecordMusicController extends GetxController {
  late final MainController mainController;
  late final AudioService _audio;

  // ─── Fichiers ────────────────────────────────────────────────────────────────
  final Rx<PlatformFile?> toplineFile   = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> recordedVoice = Rx<PlatformFile?>(null);

  // ─── État enregistrement ──────────────────────────────────────────────────────
  final isRecording    = false.obs;
  final isPlayingBack  = false.obs;

  /// Durée écoulée pendant l'enregistrement (mise à jour chaque seconde).
  final recordingElapsed = Duration.zero.obs;

  /// Barres accumulées du visualiseur (persist entre pause et reprise).
  final bars = RxList<double>([]);

  // ─── Internes ─────────────────────────────────────────────────────────────────
  late final AudioRecorder _recorder;
  StreamSubscription<Amplitude>? _amplitudeSub;
  StreamSubscription<void>?      _voiceCompleteSub;
  Timer?                         _recordingTimer;

  /// Segments WAV bruts — s'accumulent entre les pauses.
  final List<String> _segments = [];

  /// Indique si la lecture a déjà été démarrée (pour distinguer play/resume).
  bool _playbackStarted = false;

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
    _audio = Get.find<AudioService>();
    _recorder = AudioRecorder();
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
    toplineFile.value = null;
    _playbackStarted = false;
  }

  // ─── Durée max d'enregistrement ───────────────────────────────────────────────

  Duration get _maxRecordingDuration {
    if (toplineFile.value != null) {
      final toplineDur = _audio.durationRx(AudioType.topline).value;
      if (toplineDur > Duration.zero) return toplineDur;
    }
    return const Duration(minutes: 5);
  }

  // ─── Enregistrement ───────────────────────────────────────────────────────────

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    // Coupe la lecture et remet les pistes à zéro.
    await _audio.stop(AudioType.voice);
    await _audio.stop(AudioType.topline);
    isPlayingBack.value = false;
    _playbackStarted = false;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _showError('Autorisez l\'accès au microphone pour enregistrer.');
      return;
    }

    // Enregistrement en WAV (PCM brut) pour permettre la concaténation.
    final path =
        '${Directory.systemTemp.path}/voice_seg_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );

    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 80))
        .listen((amp) {
      final normalized = ((amp.current + 60) / 60).clamp(0.0, 1.0);
      bars.add(normalized);
      if (bars.length > 500) bars.removeAt(0);
    });

    // Timer durée max — incrémente depuis la durée totale déjà enregistrée.
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      recordingElapsed.value += const Duration(seconds: 1);
      if (recordingElapsed.value >= _maxRecordingDuration) _stopRecording();
    });

    isRecording.value = true;
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    await _amplitudeSub?.cancel();
    _amplitudeSub = null;

    final path = await _recorder.stop();
    isRecording.value = false;

    if (path == null) return;

    // Accumule le segment et concatène tous les segments en un seul WAV.
    _segments.add(path);
    final finalPath = await _concatenateWavSegments(_segments);

    final file = File(finalPath);
    recordedVoice.value = PlatformFile(
      path: finalPath,
      name: 'voice_record.wav',
      size: await file.length(),
    );

    // Pas de preload ici : play() rechargera le fichier correctement.
    // Réinitialise l'état de lecture pour que _startPlayback() soit appelé
    // avec le nouveau fichier.
    _playbackStarted = false;
  }

  // ─── Concaténation WAV ────────────────────────────────────────────────────────
  //
  // Structure RIFF/WAV :
  //   "RIFF" + ChunkSize(4) + "WAVE"
  //   "fmt " + fmtSize(4)   + format data
  //   ["fact" + ...]         ← chunk optionnel selon le codec/plateforme
  //   "data" + dataSize(4)  + PCM bytes
  //
  // On recherche dynamiquement le chunk "data" pour trouver l'offset exact
  // des données PCM (le header n'est PAS toujours 44 bytes sur toutes les
  // plateformes — iOS peut ajouter un chunk "fact" avant "data").

  Future<String> _concatenateWavSegments(List<String> paths) async {
    // Lecture de tous les segments.
    final files = await Future.wait(
      paths.map((p) => File(p).readAsBytes()),
    );

    // Trouve l'offset du début des données PCM dans chaque fichier.
    final offsets = files.map(_findDataOffset).toList();

    // Taille totale des données PCM (sans les headers).
    int totalPcm = 0;
    for (int i = 0; i < files.length; i++) {
      totalPcm += files[i].length - offsets[i];
    }

    // Le header de sortie est celui du premier segment (jusqu'à "data"+size).
    final firstOffset = offsets[0];
    final out = Uint8List(firstOffset + totalPcm);

    // Copie le header du premier segment (inclut "data" + ancien dataSize).
    out.setRange(0, firstOffset, files[0]);

    // Mise à jour des champs de taille (little-endian 32 bits).
    final outView = out.buffer.asByteData();
    // ChunkSize (offset 4) = total file size - 8
    outView.setUint32(4, out.length - 8, Endian.little);
    // Subchunk2Size : juste avant les PCM data = firstOffset - 4
    outView.setUint32(firstOffset - 4, totalPcm, Endian.little);

    // Empile les PCM de chaque segment.
    int cursor = firstOffset;
    for (int i = 0; i < files.length; i++) {
      final pcm = files[i].sublist(offsets[i]);
      out.setRange(cursor, cursor + pcm.length, pcm);
      cursor += pcm.length;
    }

    // Chemin unique à chaque concaténation pour éviter tout cache audioplayers.
    final outPath =
        '${Directory.systemTemp.path}/voice_final_${DateTime.now().millisecondsSinceEpoch}.wav';
    await File(outPath).writeAsBytes(out, flush: true);
    return outPath;
  }

  /// Trouve l'offset du premier octet PCM (juste après "data" + dataSize).
  /// Cherche le marqueur "data" dans les chunks RIFF pour gérer les headers
  /// non-standards (chunk "fact", etc.).
  static int _findDataOffset(Uint8List bytes) {
    // Parcourt les chunks RIFF à partir de l'offset 12 ("WAVE" est à 8-11).
    int i = 12;
    while (i + 8 <= bytes.length) {
      // ID du chunk (4 bytes ASCII).
      if (bytes[i]   == 0x64 && // 'd'
          bytes[i+1] == 0x61 && // 'a'
          bytes[i+2] == 0x74 && // 't'
          bytes[i+3] == 0x61) { // 'a'
        return i + 8; // 4 (id) + 4 (size) = données PCM
      }
      // Taille du chunk courant (little-endian).
      final chunkSize = bytes.buffer.asByteData().getUint32(i + 4, Endian.little);
      i += 8 + chunkSize;
    }
    return 44; // Fallback standard.
  }

  // ─── Suppression ─────────────────────────────────────────────────────────────

  void deleteRecording() {
    _voiceCompleteSub?.cancel();
    _voiceCompleteSub = null;
    _audio.stop(AudioType.voice);
    _audio.stop(AudioType.topline);
    isPlayingBack.value  = false;
    _playbackStarted     = false;
    recordedVoice.value  = null;
    recordingElapsed.value = Duration.zero;
    bars.clear();
    _segments.clear();
  }

  // ─── Lecture (voice + topline) ────────────────────────────────────────────────

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
    _playbackStarted = false;
    isPlayingBack.value = false;
    await _startPlayback();
  }

  Future<void> _startPlayback() async {
    final voicePath = recordedVoice.value?.path;
    if (voicePath == null) return;

    await _audio.play(AudioType.voice, voicePath);
    if (toplineFile.value?.path != null) {
      await _audio.play(AudioType.topline, toplineFile.value!.path!);
    }

    _playbackStarted = true;
    isPlayingBack.value = true;

    _voiceCompleteSub?.cancel();
    _voiceCompleteSub = _audio.onComplete(AudioType.voice).listen((_) async {
      await _audio.stop(AudioType.topline);
      isPlayingBack.value = false;
      _playbackStarted = false;
    });
  }

  // ─── Accesseurs réactifs pour la vue ─────────────────────────────────────────

  Rx<Duration> get voicePosition => _audio.positionRx(AudioType.voice);
  Rx<Duration> get voiceDuration  => _audio.durationRx(AudioType.voice);

  // ─── Navigation ───────────────────────────────────────────────────────────────

  void goToCompleteMusic() {
    Get.toNamed(
      Routes.COMPLETE_MUSIC,
      arguments: {
        'toplineFile': toplineFile.value,
        'voiceFile': recordedVoice.value,
      },
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

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
    _recordingTimer?.cancel();
    await _voiceCompleteSub?.cancel();
    await _amplitudeSub?.cancel();
    await _recorder.dispose();
    super.onClose();
  }
}
