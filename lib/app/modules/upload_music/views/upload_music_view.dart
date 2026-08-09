import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_circle_icon_button.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_icon_button.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_text_button.dart';
import 'package:swypher_flutter/shared/widgets/widgets/topline_swypher_picker_button_widget.dart';
import 'package:swypher_flutter/shared/widgets/widgets/upload_button_widget.dart';

import '../controllers/upload_music_controller.dart';

class UploadMusicView extends GetView<UploadMusicController> {
  const UploadMusicView({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(
              () =>
                  controller.toplineFile.value != null ||
                      controller.voiceFile.value != null
                  ? SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(top: 30.h, bottom: 10.h),
                      child: Text(
                        'Importer vos fichiers',
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
                        'Commencez votre projet en important une topline, votre voix, ou les deux pour un mixage complet.',
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
                        bottom: 8.h,
                        left: 10.w,
                        right: 10.w,
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                          ),
                          Container(
                            height: 4.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryLinearGradientStart,
                                  AppColors.primaryLinearGradientEnd,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ),

            Obx(
              () =>
                  controller.toplineFile.value != null ||
                      controller.voiceFile.value != null
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0:00',
                            style: TextStyle(
                              color: AppColors.secondaryTextColor.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 12.sp,
                              letterSpacing: 0.5,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            '0:00',
                            style: TextStyle(
                              color: AppColors.secondaryTextColor.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 12.sp,
                              letterSpacing: 0.5,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
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
                          CustomCircleIconButton(
                            icon: Icons.play_arrow_outlined,
                            onPressed: () {},
                          ),

                          CustomCircleIconButton(
                            icon: Icons.replay_outlined,
                            onPressed: () {},
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
                    'Topline',
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
                    'Voix',
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
              () =>controller.toplineFile.value == null ||
                      controller.voiceFile.value == null
                  ?  CustomTextButton(
                text: 'Continuer',
                onPressed: () => controller.goToCompleteMusic(),
                borderRadius: 100,
                height: 60,
              ) : SizedBox.shrink(),
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
