import 'package:get/get.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';

class MusicStudioController extends GetxController {

  void goToUploadMusic() {
    Get.toNamed(Routes.UPLOAD_MUSIC);
  }

}
