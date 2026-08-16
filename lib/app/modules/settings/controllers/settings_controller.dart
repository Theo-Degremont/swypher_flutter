import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/app/modules/settings/services/settings_service.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/data/network/auth_api.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

class SettingsController extends GetxController {
  late final MainController mainController;
  late final SettingsService _service;
  final _memory = MemoryService.instance;
  final _audio  = AudioService.to;

  final notificationsEnabled = false.obs;
  final languageExpanded     = false.obs;
  final isLoading            = false.obs;

  late final TextEditingController currentPasswordCtrl;
  late final TextEditingController newPasswordCtrl;
  late final TextEditingController confirmPasswordCtrl;

  late final FocusNode currentPasswordFocus;
  late final FocusNode newPasswordFocus;
  late final FocusNode confirmPasswordFocus;

  late final ValueNotifier<bool> currentPasswordFocused;
  late final ValueNotifier<bool> newPasswordFocused;
  late final ValueNotifier<bool> confirmPasswordFocused;

  final obscureCurrentPassword = true.obs;
  final obscureNewPassword     = true.obs;
  final obscureConfirmPassword = true.obs;

  final currentPasswordError  = Rx<String?>(null);
  final newPasswordError      = Rx<String?>(null);
  final confirmPasswordError  = Rx<String?>(null);
  final isUpdatingPassword    = false.obs;

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
    _service       = Get.find<SettingsService>();

    currentPasswordCtrl   = TextEditingController();
    newPasswordCtrl       = TextEditingController();
    confirmPasswordCtrl   = TextEditingController();

    currentPasswordFocus  = FocusNode();
    newPasswordFocus      = FocusNode();
    confirmPasswordFocus  = FocusNode();

    currentPasswordFocused = ValueNotifier(false);
    newPasswordFocused     = ValueNotifier(false);
    confirmPasswordFocused = ValueNotifier(false);

    currentPasswordFocus.addListener(() =>
        currentPasswordFocused.value = currentPasswordFocus.hasFocus);
    newPasswordFocus.addListener(() =>
        newPasswordFocused.value = newPasswordFocus.hasFocus);
    confirmPasswordFocus.addListener(() =>
        confirmPasswordFocused.value = confirmPasswordFocus.hasFocus);
  }

  @override
  void onClose() {
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    currentPasswordFocus.dispose();
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    currentPasswordFocused.dispose();
    newPasswordFocused.dispose();
    confirmPasswordFocused.dispose();
    super.onClose();
  }

  MemoryService get memory => _memory;
  bool get isLoggedIn => _memory.access != null;
  String get currentLanguageName =>
      _memory.languageCode == 'en' ? 'English' : 'Français';

  void toggleNotifications() => notificationsEnabled.toggle();

  void toggleLanguageExpanded() => languageExpanded.toggle();

  void setLanguage(String code) {
    _memory.languageCode = code;
    Get.updateLocale(Locale(code));
    languageExpanded.value = false;
  }

  Future<void> openHelpEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'theodegremontdev@gmail.com',
      query: 'subject=Support%20Swypher',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _clearPasswordErrors() {
    currentPasswordError.value = null;
    newPasswordError.value     = null;
    confirmPasswordError.value = null;
  }

  bool _validatePasswordForm() {
    _clearPasswordErrors();
    bool valid = true;

    if (currentPasswordCtrl.text.trim().isEmpty) {
      currentPasswordError.value = 'Veuillez entrer votre mot de passe actuel';
      valid = false;
    }
    if (newPasswordCtrl.text.trim().isEmpty) {
      newPasswordError.value = 'Veuillez entrer un nouveau mot de passe';
      valid = false;
    } else if (newPasswordCtrl.text.trim().length < 8) {
      newPasswordError.value = 'Le mot de passe doit contenir au moins 8 caractères';
      valid = false;
    }
    if (confirmPasswordCtrl.text.trim().isEmpty) {
      confirmPasswordError.value = 'Veuillez confirmer votre nouveau mot de passe';
      valid = false;
    } else if (newPasswordCtrl.text.trim() != confirmPasswordCtrl.text.trim()) {
      confirmPasswordError.value = 'Les mots de passe ne correspondent pas';
      valid = false;
    }

    return valid;
  }

  Future<void> updatePassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_validatePasswordForm()) return;

    isUpdatingPassword.value = true;
    final result = await _service.updatePassword(
      currentPassword: currentPasswordCtrl.text.trim(),
      newPassword:     newPasswordCtrl.text.trim(),
    );
    isUpdatingPassword.value = false;

    if (result.success) {
      currentPasswordCtrl.clear();
      newPasswordCtrl.clear();
      confirmPasswordCtrl.clear();
      Get.back();
    } else {
      currentPasswordError.value = result.error;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;

    await _service.syncPendingLikes(
      liked:    _memory.musicLikedObs.toList(),
      disliked: _memory.musicDislikedObs.toList(),
    );

    _audio.stop(AudioType.music);
    _audio.clearCurrentMusic();
    _audio.cancelMusicCompleteListener();

    // Révoquer le refresh token côté serveur avant de vider la session locale.
    // Si la requête échoue (réseau coupé, token déjà expiré), on déconnecte quand même.
    final refreshToken = _memory.refresh;
    if (refreshToken != null) {
      await Get.find<AuthApi>().logout(refreshToken: refreshToken);
    }

    await _memory.clearSessionData();

    isLoading.value = false;
    mainController.isLoggedIn.value  = false;
    mainController.currentIndex.value = 0;
    Get.back();
  }

  Future<void> deleteAccount() async {
    isLoading.value = true;
    final result = await _service.deleteAccount();
    isLoading.value = false;

    if (result.success) {
      await logout();
    } else {
      Get.snackbar(
        'Erreur',
        result.error!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.backgroundColor,
        colorText: AppColors.primaryTextColor,
        borderColor: AppColors.primaryColor.withValues(alpha: 0.4),
        borderWidth: 1,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: const Duration(seconds: 4),
      );
    }
  }

  void goToUpdatePassword() {
    Get.toNamed(Routes.UPDATE_PASSWORD);
  }

  void goToCgu() {
    Get.toNamed(Routes.CGU);
  }

  void goToPrivacyPolicy() {
    Get.toNamed(Routes.PRIVACY_POLICY);
  }
}
