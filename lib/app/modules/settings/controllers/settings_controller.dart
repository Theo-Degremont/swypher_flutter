import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/shared/data/network/auth_api.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

class SettingsController extends GetxController {
  late final MainController mainController;
  final _memory   = MemoryService.instance;
  final _authApi  = Get.find<AuthApi>();
  final _musicApi = Get.find<MusicApi>();
  final _audio    = AudioService.to;

  final notificationsEnabled = false.obs;
  final languageExpanded     = false.obs;
  final isLoading            = false.obs;

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
  }

  // ─── Getters ─────────────────────────────────────────────────────────────────

  MemoryService get memory => _memory;

  bool get isLoggedIn => _memory.access != null;

  String get currentLanguageName =>
      _memory.languageCode == 'en' ? 'English' : 'Français';

  // ─── Notifications ───────────────────────────────────────────────────────────

  void toggleNotifications() => notificationsEnabled.toggle();

  // ─── Langue ──────────────────────────────────────────────────────────────────

  void toggleLanguageExpanded() => languageExpanded.toggle();

  void setLanguage(String code) {
    _memory.languageCode = code;
    Get.updateLocale(Locale(code));
    languageExpanded.value = false;
  }

  // ─── Centre d'aide ───────────────────────────────────────────────────────────

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

  // ─── Déconnexion ─────────────────────────────────────────────────────────────

  Future<void> logout() async {
    isLoading.value = true;

    // Synchroniser les likes/dislikes en attente avant de se déconnecter.
    final liked    = _memory.musicLikedObs.toList();
    final disliked = _memory.musicDislikedObs.toList();
    if (liked.isNotEmpty)    await _musicApi.postLike(liked);
    if (disliked.isNotEmpty) await _musicApi.deleteLike(disliked);

    _audio.stop(AudioType.music);
    _audio.clearCurrentMusic();
    _audio.cancelMusicCompleteListener();

    _memory.clearSessionData();

    isLoading.value = false;
    mainController.isLoggedIn.value = false;
    mainController.currentIndex.value = 0;
    Get.back();
  }

  // ─── Suppression de compte ───────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    isLoading.value = true;
    final res = await _authApi.deleteMe();
    isLoading.value = false;

    if (res.isSuccess) {
      await logout();
    } else {
      Get.snackbar(
        'Erreur',
        res.errorMessage ?? 'Une erreur est survenue, veuillez réessayer.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: MemoryService.instance.access != null
            ? const Color(0xFF1A1025)
            : const Color(0xFF1A1025),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    }
  }
}
