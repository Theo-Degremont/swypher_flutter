import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';

class CompleteMusicController extends GetxController {
  late final MainController mainController;

  // ─── Focus nodes ────────────────────────────────────────────────────────────
  final titleMusicFocusNode = FocusNode();
  final speakingFocusNode = FocusNode();
  final titleMusicIsFocused = ValueNotifier<bool>(false);
  final speakingIsFocused = ValueNotifier<bool>(false);

  // ─── Text controllers ────────────────────────────────────────────────────────
  final titleMusicController = TextEditingController();
  final speakingController = TextEditingController();

  // ─── Cover image ─────────────────────────────────────────────────────────────
  final coverImage = Rx<File?>(null);

  // ─── Sliders ─────────────────────────────────────────────────────────────────
  final voiceVolume = 0.5.obs;
  final musicVolume = 0.5.obs;

  final RxString status = 'public'.obs;

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();

    titleMusicFocusNode.addListener(() {
      titleMusicIsFocused.value = titleMusicFocusNode.hasFocus;
    });

    speakingFocusNode.addListener(() {
      speakingIsFocused.value = speakingFocusNode.hasFocus;
    });
  }

  void updateStatus(String newStatus) {
    status.value = newStatus;
  }

  Future<void> pickCoverImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      coverImage.value = File(result.files.single.path!);
    }
  }

  @override
  void onClose() {
    titleMusicFocusNode.dispose();
    titleMusicIsFocused.dispose();
    titleMusicController.dispose();
    speakingFocusNode.dispose();
    speakingIsFocused.dispose();
    speakingController.dispose();
    super.onClose();
  }
}
