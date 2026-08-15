import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:swypher_flutter/app/modules/library/controllers/library_controller.dart';
import 'package:swypher_flutter/app/modules/profile/controllers/profile_controller.dart';
import 'package:swypher_flutter/app/modules/music_studio/controllers/music_studio_controller.dart';
import 'package:swypher_flutter/app/modules/search/controllers/search_controller.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;

  final isLoggedIn = false.obs;

  static const _protectedIndices = {2, 3, 4};

  late final HomeController home;
  late final SearchController search;
  late final LibraryController library;
  late final ProfileController profile;
  late final MusicStudioController record;

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = MemoryService.instance.access != null;

    home    = Get.find<HomeController>();
    search  = Get.find<SearchController>();
    library = Get.find<LibraryController>();
    profile = Get.find<ProfileController>();
    record  = Get.find<MusicStudioController>();
  }

  void changePage(int index) {
    if (_protectedIndices.contains(index) && !isLoggedIn.value) {
      _goToLogin();
      return;
    }

    // La musique s'arrête uniquement quand on va au studio (bouton central).
    if (index == 4) {
      AudioService.to.stop(AudioType.music);
      AudioService.to.clearCurrentMusic();
      AudioService.to.cancelMusicCompleteListener();
    }

    // Réinitialise les données du profil quand on quitte l'onglet (sans couper la musique).
    if (currentIndex.value == 3 && index != 3) {
      profile.resetData();
    }

    // Rafraîchit la library quand on arrive sur l'onglet.
    if (index == 2) {
      library.reloadLiked();
    }

    currentIndex.value = index;
  }

  Future<void> _goToLogin() async {
    await Get.toNamed(Routes.LOGIN);
    currentIndex.value = 0;
    isLoggedIn.value = MemoryService.instance.access != null;
  }
}
