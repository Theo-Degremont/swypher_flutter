import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:swypher_flutter/app/modules/library/controllers/library_controller.dart';
import 'package:swypher_flutter/app/modules/library/services/library_service.dart';
import 'package:swypher_flutter/app/modules/profile/controllers/profile_controller.dart';
import 'package:swypher_flutter/app/modules/music_studio/controllers/music_studio_controller.dart';
import 'package:swypher_flutter/app/modules/profile/services/profile_service.dart';
import 'package:swypher_flutter/app/modules/search/controllers/search_controller.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Services partagés
    Get.put<AudioService>(AudioService());
    Get.put<MusicApi>(MusicApi());

    // Sous-contrôleurs enregistrés en premier (MainController en dépend)
    Get.put<HomeController>(HomeController());
    Get.put<SearchPageController>(SearchPageController());
    Get.put<LibraryService>(LibraryService());
    Get.put<LibraryController>(LibraryController());
    Get.put<ProfileService>(ProfileService());
    Get.put<ProfileController>(ProfileController());
    Get.put<MusicStudioController>(MusicStudioController());

    // Contrôleur central en dernier
    Get.lazyPut<MainController>(() => MainController());
  }
}
