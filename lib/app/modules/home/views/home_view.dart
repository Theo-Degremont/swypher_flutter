import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
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
              'Aucune musique pour le moment',
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
          // ─── Tabs ──────────────────────────────────────────────────────────
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => controller.selectTab(0),
                  child: Obx(() {
                    final selected = controller.selectedTab.value == 0;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Musiques'.toUpperCase(),
                          style: TextStyle(
                            color: selected
                                ? AppColors.primaryColor
                                : AppColors.secondaryTextColor,
                            fontSize: 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (selected) ...[
                          SizedBox(height: 4.h),
                          Container(
                            width: 40.w,
                            height: 3.h,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ],
                    );
                  }),
                ),
                SizedBox(width: 20.w),
                GestureDetector(
                  onTap: () => controller.selectTab(1),
                  child: Obx(() {
                    final selected = controller.selectedTab.value == 1;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Prods'.toUpperCase(),
                          style: TextStyle(
                            color: selected
                                ? AppColors.primaryColor
                                : AppColors.secondaryTextColor,
                            fontSize: 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (selected) ...[
                          SizedBox(height: 4.h),
                          Container(
                            width: 50.w,
                            height: 3.h,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),

          // ─── Feed ──────────────────────────────────────────────────────────
          Expanded(
            flex: 9,
            child: Obx(() {
              // IndexedStack garde les deux PageViews en mémoire pour ne pas
              // recréer les widgets au changement d'onglet.
              return IndexedStack(
                index: controller.selectedTab.value,
                children: [
                  // ── Onglet Musiques ─────────────────────────────────────
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

                  // ── Onglet Toplines ─────────────────────────────────────
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
