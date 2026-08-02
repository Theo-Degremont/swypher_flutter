import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:swypher_flutter/app/modules/library/controllers/library_controller.dart';
import 'package:swypher_flutter/app/modules/profile/controllers/profile_controller.dart';
import 'package:swypher_flutter/app/modules/music_studio/controllers/music_studio_controller.dart';
import 'package:swypher_flutter/app/modules/search/controllers/search_controller.dart';
import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Sous-contrôleurs enregistrés en premier (MainController en dépend)
    Get.put<HomeController>(HomeController());
    Get.put<SearchPageController>(SearchPageController());
    Get.put<LibraryController>(LibraryController());
    Get.put<ProfileController>(ProfileController());
    Get.put<MusicStudioController>(MusicStudioController());

    // Contrôleur central en dernier
    Get.lazyPut<MainController>(() => MainController());
  }
}
