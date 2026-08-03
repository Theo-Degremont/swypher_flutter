import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';

class RegisterController extends GetxController {
  late final MainController mainController;

  final usernameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final usernameIsFocused = ValueNotifier<bool>(false);
  final emailIsFocused = ValueNotifier<bool>(false);
  final passwordIsFocused = ValueNotifier<bool>(false);

  final RxBool isPasswordVisible = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
    usernameFocusNode.addListener(() {
      usernameIsFocused.value = usernameFocusNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      emailIsFocused.value = emailFocusNode.hasFocus;
    });
    passwordFocusNode.addListener(() {
      passwordIsFocused.value = passwordFocusNode.hasFocus;
    });
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onClose() {
    usernameFocusNode.dispose();
    usernameIsFocused.dispose();
    emailFocusNode.dispose();
    emailIsFocused.dispose();
    passwordFocusNode.dispose();
    passwordIsFocused.dispose();
    super.onClose();
  }
}
