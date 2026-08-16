import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_circle_icon_button.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_icon_button.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_text_button.dart';
import 'package:swypher_flutter/shared/widgets/widgets/progression_bar_widget.dart';
import 'package:swypher_flutter/shared/widgets/widgets/topline_swypher_picker_button_widget.dart';
import 'package:swypher_flutter/shared/widgets/widgets/upload_button_widget.dart';

import '../controllers/upload_music_controller.dart';

class UploadMusicView extends GetView<UploadMusicController> {
  const UploadMusicView({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      body: Padding(
        padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 30.h, bottom: 20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(
              () =>
                  controller.toplineFile.value != null ||
                      controller.voiceFile.value != null
                  ? SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only( bottom: 10.h),
                      child: Text(
                        tkTitleUploadMusic.tr,
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: AppColors.primaryTextColor,
                          letterSpacing: -0.5,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            Obx(
              () =>
                  controller.toplineFile.value != null ||
                      controller.voiceFile.value != null
                  ? SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        tkUploadMusicSubtitle.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.secondaryTextColor,
                          letterSpacing: 0.5,

                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
            ),
            Obx(
              () =>
                  controller.toplineFile.value != null ||
                      controller.voiceFile.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: 30.h,
                        left: 10.w,
                        right: 10.w,
                      ),
                      child: Obx(
                        () => ProgressionBarWidget(
                          position: controller.playbackPosition,
                          duration: controller.playbackDuration,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
            Obx(
              () =>
                  controller.toplineFile.value != null ||
                      controller.voiceFile.value != null
                  ? Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 50.w,
                        children: [
                          Obx(
                            () => CustomCircleIconButton(
                              icon: controller.isPlayingBack.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_outlined,
                              onPressed: controller.togglePlayback,
                            ),
                          ),
                          CustomCircleIconButton(
                            icon: Icons.replay_outlined,
                            onPressed: controller.restartPlayback,
                            colorBackground: AppColors.whiteColor.withValues(
                              alpha: 0.1,
                            ),
                            colorIcon: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.h, bottom: 10.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 10.h,
                children: [
                  Text(
                    tkTabTopline.tr,
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: AppColors.primaryTextColor,
                      letterSpacing: -0.5,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Obx(
                    () => UploadButtonWidget(
                      fileName: controller.toplineFile.value?.name,
                      onTap: controller.pickToplineFile,
                      onRemove: controller.removeToplineFile,
                    ),
                  ),
                  Obx(
                    () => controller.toplineFile.value != null
                        ? SizedBox.shrink()
                        : ToplineSwypherPickerButtonWidget(onTap: () {}),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.h, bottom: 30.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 10.h,
                children: [
                  Text(
                    tkUploadVoice.tr,
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: AppColors.primaryTextColor,
                      letterSpacing: -0.5,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Obx(
                    () => UploadButtonWidget(
                      fileName: controller.voiceFile.value?.name,
                      onTap: controller.pickVoiceFile,
                      onRemove: controller.removeVoiceFile,
                    ),
                  ),
                ],
              ),
            ),

            Obx(
              () =>controller.toplineFile.value != null ||
                      controller.voiceFile.value != null
                  ?  CustomTextButton(
                text: tkBtnContinue.tr,
                onPressed: () => controller.goToCompleteMusic(),
                borderRadius: 100,
                height: 60,
              ) : SizedBox(height: 60.h),
            ),
          ],
        ),
      ),
      showNavBar: false,
      showBackButton: true,
      mainController: controller.mainController,
    );
  }
}
