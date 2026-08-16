import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/single_music/services/single_music_service.dart';

import '../controllers/single_music_controller.dart';

class SingleMusicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SingleMusicService>(
      () => SingleMusicService(),
    );
    Get.lazyPut<SingleMusicController>(
      () => SingleMusicController(),
    );
  }
}
