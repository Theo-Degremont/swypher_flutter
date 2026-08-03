import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:swypher_flutter/app/modules/library/controllers/library_controller.dart';
import 'package:swypher_flutter/app/modules/profile/controllers/profile_controller.dart';
import 'package:swypher_flutter/app/modules/music_studio/controllers/music_studio_controller.dart';
import 'package:swypher_flutter/app/modules/search/controllers/search_controller.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';

class MainController extends GetxController {
  // Index de la page courante (0=Home, 1=Search, 2=Library, 3=Profile, 4=Record)
  final currentIndex = 0.obs;

  // Références directes aux sous-contrôleurs
  late final HomeController home;
  late final SearchPageController search;
  late final LibraryController library;
  late final ProfileController profile;
  late final MusicStudioController record;

  @override
  void onInit() {
    super.onInit();
    home = Get.find<HomeController>();
    search = Get.find<SearchPageController>();
    library = Get.find<LibraryController>();
    profile = Get.find<ProfileController>();
    record = Get.find<MusicStudioController>();
  }

  void changePage(int index) {
    if (index == 0) {
      home.onInit();
    } else if (index == 1) {
      search.onInit();
    } else if (index == 2) {
      library.onInit();
    } else if (index == 3) {
      goToLogin();
      profile.onInit();
    } else if (index == 4) {
      record.onInit();
    }
    currentIndex.value = index;
    
  }

  void goToLogin() {
    Get.toNamed(Routes.LOGIN); // Index de la page d'inscription
  }


  
}
