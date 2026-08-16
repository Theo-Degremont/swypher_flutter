import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/constants/text_keys.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_tab_bar.dart';
import 'package:swypher_flutter/shared/widgets/widgets/music_card_widget.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final isEmpty =
          controller.musicList.isEmpty && controller.toplineList.isEmpty;

      if (isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              tkHomeNoMusic.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 20.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Obx(() => CustomTabBar(
                tabs: [tkTabMusics.tr, tkTabProds.tr],
                selectedIndex: controller.selectedTab.value,
                onTap: controller.selectTab,
                activeColor: AppColors.primaryColor,
                spacing: 20,
                indicatorWidth: 40,
              )),
            ),
          ),

          Expanded(
            flex: 9,
            child: Obx(() {
              return IndexedStack(
                index: controller.selectedTab.value,
                children: [
                  Obx(() {
                    if (controller.musicList.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return PageView.builder(
                      controller: controller.musicPageController,
                      scrollDirection: Axis.vertical,
                      itemCount: controller.musicList.length,
                      onPageChanged: controller.onMusicPageChanged,
                      itemBuilder: (_, index) =>
                          MusicCardWidget(music: controller.musicList[index]),
                    );
                  }),

                  Obx(() {
                    if (controller.toplineList.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return PageView.builder(
                      controller: controller.toplinePageController,
                      scrollDirection: Axis.vertical,
                      itemCount: controller.toplineList.length,
                      onPageChanged: controller.onToplinePageChanged,
                      itemBuilder: (_, index) =>
                          MusicCardWidget(music: controller.toplineList[index]),
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      );
    });
  }
}
