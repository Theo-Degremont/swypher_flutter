import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';

class UploadMusicController extends GetxController {
  late final MainController mainController;
  late final AudioService _audio;

  final Rx<PlatformFile?> toplineFile = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> voiceFile   = Rx<PlatformFile?>(null);

  final isPlayingBack = false.obs;
  bool _playbackStarted = false;
  StreamSubscription<void>? _completeSub;

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
    _audio         = Get.find<AudioService>();
  }

  // ─── Topline ──────────────────────────────────────────────────────────────────

  Future<void> pickToplineFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac', 'webm'],
    );
    if (result == null) return;

    await _stopAll();
    toplineFile.value = result.files.single;
    final path = result.files.single.path;
    if (path != null) await _audio.preload(AudioType.topline, path);
  }

  Future<void> removeToplineFile() async {
    await _stopAll();
    toplineFile.value = null;
  }

  // ─── Voice ────────────────────────────────────────────────────────────────────

  Future<void> pickVoiceFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac', 'webm'],
    );
    if (result == null) return;

    await _stopAll();
    voiceFile.value = result.files.single;
    final path = result.files.single.path;
    if (path != null) await _audio.preload(AudioType.voice, path);
  }

  Future<void> removeVoiceFile() async {
    await _stopAll();
    voiceFile.value = null;
  }

  // ─── Lecture ──────────────────────────────────────────────────────────────────

  Future<void> togglePlayback() async {
    if (isPlayingBack.value) {
      if (toplineFile.value != null) await _audio.pause(AudioType.topline);
      if (voiceFile.value != null)   await _audio.pause(AudioType.voice);
      isPlayingBack.value = false;
    } else {
      if (!_playbackStarted) {
        await _startPlayback();
      } else {
        if (toplineFile.value != null) await _audio.resume(AudioType.topline);
        if (voiceFile.value != null)   await _audio.resume(AudioType.voice);
        isPlayingBack.value = true;
      }
    }
  }

  Future<void> restartPlayback() async {
    await _stopAll();
    await _startPlayback();
  }

  Future<void> _startPlayback() async {
    if (toplineFile.value?.path == null && voiceFile.value?.path == null) return;

    if (toplineFile.value?.path != null) {
      await _audio.play(AudioType.topline, toplineFile.value!.path!);
    }
    if (voiceFile.value?.path != null) {
      await _audio.play(AudioType.voice, voiceFile.value!.path!);
    }

    _playbackStarted    = true;
    isPlayingBack.value = true;

    // Écoute la fin de la piste principale pour réinitialiser l'état.
    final mainType = toplineFile.value != null ? AudioType.topline : AudioType.voice;
    _completeSub?.cancel();
    _completeSub = _audio.onComplete(mainType).listen((_) async {
      await _stopAll();
      _playbackStarted = false;
    });
  }

  Future<void> _stopAll() async {
    _completeSub?.cancel();
    _completeSub    = null;
    _playbackStarted = false;
    await _audio.stop(AudioType.topline);
    await _audio.stop(AudioType.voice);
    isPlayingBack.value = false;
  }

  // ─── Accesseurs réactifs ──────────────────────────────────────────────────────

  /// Position de la piste principale (topline si dispo, sinon voice).
  Rx<Duration> get playbackPosition => toplineFile.value != null
      ? _audio.positionRx(AudioType.topline)
      : _audio.positionRx(AudioType.voice);

  /// Durée de la piste principale (topline si dispo, sinon voice).
  Rx<Duration> get playbackDuration => toplineFile.value != null
      ? _audio.durationRx(AudioType.topline)
      : _audio.durationRx(AudioType.voice);

  // ─── Navigation ───────────────────────────────────────────────────────────────

  void goToCompleteMusic() {
    Get.toNamed(
      Routes.COMPLETE_MUSIC,
      arguments: {
        'toplineFile': toplineFile.value,
        'voiceFile':   voiceFile.value,
      },
    );
  }

  @override
  void onClose() async {
    _completeSub?.cancel();
    await _audio.stop(AudioType.topline);
    await _audio.stop(AudioType.voice);
    super.onClose();
  }
}
