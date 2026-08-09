import 'package:get/get.dart';

import '../controllers/complete_music_controller.dart';

class CompleteMusicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompleteMusicController>(
      () => CompleteMusicController(),
    );
  }
}
