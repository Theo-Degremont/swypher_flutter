import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/complete_music/services/complete_music_service.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';

import '../controllers/complete_music_controller.dart';

class CompleteMusicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MusicApi>(() => MusicApi());
    Get.lazyPut<CompleteMusicService>(() => CompleteMusicService());
    Get.lazyPut<CompleteMusicController>(() => CompleteMusicController());
  }
}
