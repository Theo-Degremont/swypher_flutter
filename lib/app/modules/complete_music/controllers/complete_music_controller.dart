import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/complete_music/services/complete_music_service.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class CompleteMusicController extends GetxController {
  late final MainController mainController;
  late final CompleteMusicService _service;

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

  // ─── Status & loading ────────────────────────────────────────────────────────
  final RxString status    = 'public'.obs;
  final isLoading          = false.obs;

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
    _service       = Get.find<CompleteMusicService>();

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
  }

  void updateStatus(String newStatus) => status.value = newStatus;

  Future<void> pickCoverImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      coverImage.value = File(result.files.single.path!);
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
  void onClose() {
    titleMusicFocusNode.dispose();
    speakingFocusNode.dispose();
    titleMusicIsFocused.dispose();
    speakingIsFocused.dispose();
    titleMusicController.dispose();
    speakingController.dispose();
    super.onClose();
  }
}
