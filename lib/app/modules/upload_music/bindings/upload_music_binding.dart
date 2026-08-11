import 'package:get/get.dart';

import '../controllers/upload_music_controller.dart';

class UploadMusicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadMusicController>(
      () => UploadMusicController(),
    );
  }
}
