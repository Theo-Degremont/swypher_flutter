import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/login/services/login_service.dart';

import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
    Get.lazyPut<LoginService>(
      () => LoginService(),
    );
  }
}
