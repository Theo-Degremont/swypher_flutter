import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';

class UploadMusicController extends GetxController {
  late final MainController mainController;

  final Rx<PlatformFile?> toplineFile = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> voiceFile = Rx<PlatformFile?>(null);

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
  }

  Future<void> pickToplineFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac', 'webm'],
    );

    if (result != null) {
      toplineFile.value = result.files.single;
    }
  }

  Future<void> pickVoiceFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac', 'webm'],
    );

    if (result != null) {
      voiceFile.value = result.files.single;
    }
  }

  void removeToplineFile() {
    toplineFile.value = null;
  }

  void removeVoiceFile() {
    voiceFile.value = null;
  }
}
