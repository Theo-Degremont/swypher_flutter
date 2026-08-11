import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/complete_music/services/complete_music_service.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';

class CompleteMusicController extends GetxController {
  late final MainController mainController;
  late final CompleteMusicService _service;
  late final AudioService _audio;

  // ─── Fichiers audio reçus depuis UploadMusicView ─────────────────────────────
  PlatformFile? toplineFile;
  PlatformFile? voiceFile;

  // ─── Focus nodes ────────────────────────────────────────────────────────────
  final titleMusicFocusNode = FocusNode();
  final speakingFocusNode   = FocusNode();

  final titleMusicIsFocused = ValueNotifier<bool>(false);
  final speakingIsFocused   = ValueNotifier<bool>(false);

  // ─── Text controllers ────────────────────────────────────────────────────────
  final titleMusicController = TextEditingController();
  final speakingController   = TextEditingController();

  // ─── Cover image ─────────────────────────────────────────────────────────────
  final coverImage = Rx<File?>(null);

  // ─── Sliders ─────────────────────────────────────────────────────────────────
  final voiceVolume = 0.5.obs;
  final musicVolume = 0.5.obs;

  // ─── Lecture aperçu ──────────────────────────────────────────────────────────
  final isPlayingBack  = false.obs;
  bool _playbackStarted = false;
  StreamSubscription<void>? _voiceCompleteSub;

  // ─── Status & loading ────────────────────────────────────────────────────────
  final RxString status    = 'public'.obs;
  final isLoading          = false.obs;

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
    _service       = Get.find<CompleteMusicService>();
    _audio         = Get.find<AudioService>();

    // Récupération des fichiers passés depuis UploadMusicView
    final args = Get.arguments as Map<String, dynamic>?;
    toplineFile = args?['toplineFile'] as PlatformFile?;
    voiceFile   = args?['voiceFile']   as PlatformFile?;

    titleMusicFocusNode.addListener(() {
      titleMusicIsFocused.value = titleMusicFocusNode.hasFocus;
    });
    speakingFocusNode.addListener(() {
      speakingIsFocused.value = speakingFocusNode.hasFocus;
    });

    // Synchronise les sliders avec l'AudioService en temps réel.
    // Le changement de slider est immédiatement appliqué même pendant la lecture.
    ever(voiceVolume, (double v) => _audio.setVolume(AudioType.voice, v));
    ever(musicVolume, (double v) => _audio.setVolume(AudioType.topline, v));
  }

  // ─── Lecture aperçu (voice + topline) ────────────────────────────────────────

  Future<void> togglePlayback() async {
    if (isPlayingBack.value) {
      await _audio.pause(AudioType.voice);
      if (toplineFile != null) await _audio.pause(AudioType.topline);
      isPlayingBack.value = false;
    } else {
      if (!_playbackStarted) {
        await _startPlayback();
      } else {
        await _audio.resume(AudioType.voice);
        if (toplineFile?.path != null) await _audio.resume(AudioType.topline);
        isPlayingBack.value = true;
      }
    }
  }

  Future<void> _startPlayback() async {
    final voicePath = voiceFile?.path;
    if (voicePath == null) return;

    // Applique les volumes des sliders dès le démarrage de la lecture.
    await _audio.play(AudioType.voice, voicePath, volume: voiceVolume.value);
    if (toplineFile?.path != null) {
      await _audio.play(AudioType.topline, toplineFile!.path!, volume: musicVolume.value);
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

  Rx<Duration> get voicePosition => _audio.positionRx(AudioType.voice);
  Rx<Duration> get voiceDuration  => _audio.durationRx(AudioType.voice);

  // ─────────────────────────────────────────────────────────────────────────────

  void updateStatus(String newStatus) => status.value = newStatus;

  Future<void> pickCoverImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      coverImage.value = File(picked.path);
    }
  }

  Future<void> postMusic() async {
    final title = titleMusicController.text.trim();
    if (title.isEmpty) {
      _showError('Le titre de la musique est requis.');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _service.postMusic(
        title: title,
        status: status.value,
        topline: toplineFile,
        voice: voiceFile,
        coverImage: coverImage.value,
        voiceVolume: voiceVolume.value,
        musicVolume: musicVolume.value,
      );

      if (response.isSuccess) {
        // Retour à la page principale sur l'onglet home
        mainController.changePage(0);
        Get.until((route) => route.isFirst);
      } else {
        _showError(response.errorMessage ?? 'Une erreur est survenue.');
      }
    } finally {
      isLoading.value = false;
    }
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
    _voiceCompleteSub?.cancel();
    await _audio.stop(AudioType.voice);
    await _audio.stop(AudioType.topline);
    titleMusicFocusNode.dispose();
    speakingFocusNode.dispose();
    titleMusicIsFocused.dispose();
    speakingIsFocused.dispose();
    titleMusicController.dispose();
    speakingController.dispose();
    super.onClose();
  }
}
