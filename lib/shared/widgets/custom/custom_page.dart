import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_app_bar.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_nav_bar.dart';
import 'package:swypher_flutter/shared/widgets/widgets/bottom_listen_music_widget.dart';

class CustomPage extends StatelessWidget {
  const CustomPage({
    super.key,
    this.showBackButton = false,
    this.showNavBar = true,
    this.resizeToAvoidBottomInset = false,
    required this.body,
    required this.mainController,
  });

  final bool showBackButton;
  final bool showNavBar;
  final bool resizeToAvoidBottomInset;
  final Widget body;
  final MainController mainController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Column(
        children: [
          Expanded(
            flex: 12,
            child: CustomAppBar(showBackButton: showBackButton),
          ),
          Expanded(
            flex: showNavBar ? 78 : 88,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: -150.w,
                  left: -50.h,
                  child: Container(
                    width: 200.w,
                    height: 400.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      // color: AppColors.whiteColor,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 120,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150.w,
                  right: -50.h,
                  child: Container(
                    width: 200.w,
                    height: 400.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      // color: AppColors.whiteColor,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 120,
                        ),
                      ],
                    ),
                  ),
                ),
                body,
                Obx(() {
                  final tab = mainController.currentIndex.value;
                  final music = AudioService.to.currentMusicObs.value;
                  if (music == null || tab == 0 || tab == 4) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: BottomListenMusicWidget(
                      music: music,
                      coverUrl: AudioService.to.currentCoverUrlObs.value,
                      onTogglePlay: AudioService.to.toggleMusicPlay,
                      formatDuration: AudioService.formatDuration,
                    ),
                  );
                }),
              ],
            ),
          ),
          if (showNavBar)
            Expanded(
              flex: 10,
              child: Obx(
                () => CustomNavBar(
                  currentIndex: mainController.currentIndex.value,
                  onTabSelected: mainController.changePage,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
