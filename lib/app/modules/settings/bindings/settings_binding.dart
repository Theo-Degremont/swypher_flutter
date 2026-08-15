import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/settings/services/settings_service.dart';

import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsService>(
      () => SettingsService(),
    );
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
    );
  }
}
