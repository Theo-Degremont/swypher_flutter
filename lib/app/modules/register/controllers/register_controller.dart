import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/app/modules/register/services/register_service.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class RegisterController extends GetxController {
  late final MainController mainController;
  late final RegisterService _registerService;

  // ─── Focus nodes ────────────────────────────────────────────────────────────
  final usernameFocusNode = FocusNode();
  final emailFocusNode    = FocusNode();
  final passwordFocusNode = FocusNode();

  final usernameIsFocused = ValueNotifier<bool>(false);
  final emailIsFocused    = ValueNotifier<bool>(false);
  final passwordIsFocused = ValueNotifier<bool>(false);

  // ─── Text controllers ────────────────────────────────────────────────────────
  final usernameController = TextEditingController();
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  // ─── UI state ────────────────────────────────────────────────────────────────
  final isPasswordVisible = false.obs;
  final isLoading         = false.obs;
  final isButtonEnabled   = true.obs;

  // ─── Field errors ────────────────────────────────────────────────────────────
  final usernameError = RxnString();
  final emailError    = RxnString();
  final passwordError = RxnString();

  Timer? _cooldownTimer;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    mainController   = Get.find<MainController>();
    _registerService = Get.find<RegisterService>();

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

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    usernameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    usernameIsFocused.dispose();
    emailIsFocused.dispose();
    passwordIsFocused.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void _clearErrors() {
    usernameError.value = null;
    emailError.value    = null;
    passwordError.value = null;
  }

  void _startCooldown() {
    isButtonEnabled.value = false;
    _cooldownTimer = Timer(const Duration(seconds: 3), () {
      isButtonEnabled.value = true;
    });
  }

  Future<void> register() async {
    if (!isButtonEnabled.value || isLoading.value) return;

    _clearErrors();
    isLoading.value = true;

    final response = await _registerService.register(
      pseudo:   usernameController.text.trim(),
      email:    emailController.text.trim(),
      password: passwordController.text,
    );

    isLoading.value = false;

    print('=== REGISTER RESPONSE ===');
    print('success     : ${response.success}');
    print('statusCode  : ${response.statusCode}');
    print('message     : ${response.message}');
    print('data        : ${response.data}');
    print('errors      : ${response.errors?.map((e) => '{field: ${e.field}, message: ${e.message}}').toList()}');
    print('meta        : ${response.meta}');
    print('=========================');

    if (response.isSuccess) {
      Get.offAllNamed(Routes.MAIN);
      return;
    }

    // Erreurs par champ
    usernameError.value = response.fieldError('pseudo');
    emailError.value    = response.fieldError('email');
    passwordError.value = response.fieldError('password');

    // Erreur globale en toast si aucune erreur de champ
    final hasFieldErrors = usernameError.value != null ||
        emailError.value != null ||
        passwordError.value != null;

    if (!hasFieldErrors && response.errorMessage != null) {
      Get.snackbar(
        'Erreur',
        response.errorMessage!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.backgroundColor,
        colorText: AppColors.primaryTextColor,
        borderColor: AppColors.primaryColor.withValues(alpha: 0.4),
        borderWidth: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: const Duration(seconds: 4),
      );
    }

    _startCooldown();
  }
}
