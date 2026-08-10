import 'package:get/get.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';

import '../controllers/record_music_controller.dart';

class RecordMusicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecordMusicController>(
      () => RecordMusicController(),
    );
  }
}
