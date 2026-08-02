import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/home/views/home_view.dart';
import 'package:swypher_flutter/app/modules/library/views/library_body.dart';
import 'package:swypher_flutter/app/modules/profile/views/profile_view.dart';
import 'package:swypher_flutter/app/modules/music_studio/views/music_studio_view.dart';
import 'package:swypher_flutter/app/modules/search/views/search_view.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_app_bar.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_nav_bar.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      showBackButton: false,
      showNavBar: true,
      mainController: controller,
      body: Obx(
              () => IndexedStack(
                index: controller.currentIndex.value,
                children: const [
                  HomeView(), // 0
                  SearchView(), // 1
                  MusicStudioView(), // 2
                  ProfileView(), // 3
                  MusicStudioView(), // 4
                ],
              ),
            ),
    );
  
  }
}
