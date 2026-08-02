import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:swypher_flutter/app/modules/library/controllers/library_controller.dart';
import 'package:swypher_flutter/app/modules/profile/controllers/profile_controller.dart';
import 'package:swypher_flutter/app/modules/music_studio/controllers/music_studio_controller.dart';
import 'package:swypher_flutter/app/modules/search/controllers/search_controller.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class MainController extends GetxController {
  // Index de la page courante (0=Home, 1=Search, 2=Library, 3=Profile, 4=Record)
  final currentIndex = 0.obs;

  // Couleur de fond dynamique de la navbar selon la page active
  final navBarColor = Rx<Color>(AppColors.backgroundColor);

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
    currentIndex.value = index;
    _updateNavBarColor(index);
  }

  void _updateNavBarColor(int index) {
    switch (index) {
      case 0:
        navBarColor.value = AppColors.backgroundColor;
      case 1:
        navBarColor.value = AppColors.backgroundColor;
      case 2:
        navBarColor.value = AppColors.backgroundColor;
      case 3:
        navBarColor.value = AppColors.backgroundColor;
      case 4:
        navBarColor.value = AppColors.backgroundColor;
    }
  }
}
