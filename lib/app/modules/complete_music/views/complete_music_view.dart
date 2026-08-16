import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_field.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_text_button.dart';
import 'package:swypher_flutter/shared/widgets/widgets/image_cover_button.dart';
import 'package:swypher_flutter/shared/widgets/widgets/play_button_widget.dart';
import 'package:swypher_flutter/shared/widgets/widgets/progression_bar_widget.dart';
import 'package:swypher_flutter/shared/widgets/widgets/slider_widget.dart';

import '../controllers/complete_music_controller.dart';

class CompleteMusicView extends GetView<CompleteMusicController> {
  const CompleteMusicView({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: CustomPage(
        showNavBar: false,
        showBackButton: true,
        body: Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 20.h,
            bottom: 20.h,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: AppColors.whiteColor.withValues(alpha: 0.1),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 15.w,
                      children: [
                        Obx(
                          () => PlayButtonWidget(
                            size: 55.0,
                            iconSize: 35.0,
                            isPlaying: controller.isPlayingBack.value,
                            onPressed: controller.togglePlayback,
                          ),
                        ),
                        Expanded(
                          child: ProgressionBarWidget(
                            position: controller.voicePosition,
                            duration: controller.voiceDuration,
                            infoInTop: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (Rect rect) =>
                          const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black,
                              Colors.black,
                              Colors.black,
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.08, 0.5, 0.98, 1.0],
                          ).createShader(
                            Rect.fromLTWH(0, 0, rect.width, rect.height),
                          ),
                      blendMode: BlendMode.dstIn,
                      child: ListView(
                        padding: EdgeInsets.only(top: 30.h, bottom: 30.h),
                        children: [
                          CustomField(
                            controller: controller.titleMusicController,
                            isFocused: controller.titleMusicIsFocused,
                            focusNode: controller.titleMusicFocusNode,
                            hintText: tkCompleteMusicTitleHint.tr,
                            keyboardType: TextInputType.name,
                            labelText: tkCompleteMusicTitleLabel.tr,
                            fontFamilyLabel: AppFonts.poppins,
                            textColorLabel: AppColors.primaryTextColor,
                            fontSizeLabel: 16.0,
                            fontWeightLabel: FontWeight.normal,
                          ),

                          CustomField(
                            controller: controller.speakingController,
                            isFocused: controller.speakingIsFocused,
                            focusNode: controller.speakingFocusNode,
                            hintText: tkCompleteMusicLyricsHint.tr,
                            keyboardType: TextInputType.multiline,
                            labelText: tkCompleteMusicLyricsLabel.tr,
                            fontFamilyLabel: AppFonts.poppins,
                            textColorLabel: AppColors.primaryTextColor,
                            fontSizeLabel: 16.0,
                            fontWeightLabel: FontWeight.normal,
                            isExpandable: true,
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: Text(
                              tkCompleteMusicCover.tr,
                              style: TextStyle(
                                color: AppColors.primaryTextColor,
                                fontSize: 16.sp,
                                fontFamily: AppFonts.poppins,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          Obx(
                            () => ImageCoverButton(
                              onTap: controller.pickCoverImage,
                              imageFile: controller.coverImage.value,
                              height: 300.h,
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: Text(
                              tkCompleteMusicVolumeSettings.tr,
                              style: TextStyle(
                                color: AppColors.primaryTextColor,
                                fontSize: 16.sp,
                                fontFamily: AppFonts.poppins,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: AppColors.whiteColor.withValues(
                                  alpha: 0.1,
                                ),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              spacing: 15.h,
                              children: [
                                Obx(
                                  () => SliderWidget(
                                    label: tkCompleteMusicVolumeVoice.tr,
                                    value: controller.voiceVolume.value,
                                    onChanged: (v) =>
                                        controller.voiceVolume.value = v,
                                  ),
                                ),
                                Obx(
                                  () => SliderWidget(
                                    label: tkCompleteMusicVolumeMusic.tr,
                                    value: controller.musicVolume.value,
                                    onChanged: (v) =>
                                        controller.musicVolume.value = v,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: Text(
                              tkCompleteMusicVisibility.tr,
                              style: TextStyle(
                                color: AppColors.primaryTextColor,
                                fontSize: 16.sp,
                                fontFamily: AppFonts.poppins,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
                            padding: EdgeInsets.all(5.w),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: AppColors.whiteColor.withValues(
                                  alpha: 0.1,
                                ),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => GestureDetector(
                                      onTap: () =>
                                          controller.updateStatus('published'),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              controller.status.value ==
                                                      'published'
                                                  ? AppColors
                                                        .primaryLinearGradientStart
                                                  : Colors.transparent,
                                              controller.status.value ==
                                                      'published'
                                                  ? AppColors
                                                        .primaryLinearGradientEnd
                                                  : Colors.transparent,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        child: Text(
                                          tkVisibilityPublic.tr,
                                          style: TextStyle(
                                            color:
                                                controller.status.value ==
                                                    'published'
                                                ? AppColors.secondaryColor
                                                : AppColors.primaryTextColor,
                                            fontSize: 14.sp,
                                            fontFamily: AppFonts.montserrat,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Obx(
                                    () => GestureDetector(
                                      onTap: () =>
                                          controller.updateStatus('private'),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              controller.status.value ==
                                                      'private'
                                                  ? AppColors
                                                        .primaryLinearGradientStart
                                                  : Colors.transparent,
                                              controller.status.value ==
                                                      'private'
                                                  ? AppColors
                                                        .primaryLinearGradientEnd
                                                  : Colors.transparent,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        child: Text(
                                          tkVisibilityPrivate.tr,
                                          style: TextStyle(
                                            color:
                                                controller.status.value ==
                                                    'private'
                                                ? AppColors.secondaryColor
                                                : AppColors.primaryTextColor,
                                            fontSize: 14.sp,
                                            fontFamily: AppFonts.montserrat,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Obx(
                                    () => GestureDetector(
                                      onTap: () =>
                                          controller.updateStatus('draft'),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              controller.status.value == 'draft'
                                                  ? AppColors
                                                        .primaryLinearGradientStart
                                                  : Colors.transparent,
                                              controller.status.value == 'draft'
                                                  ? AppColors
                                                        .primaryLinearGradientEnd
                                                  : Colors.transparent,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        child: Text(
                                          tkTabDraft.tr,
                                          style: TextStyle(
                                            color:
                                                controller.status.value ==
                                                    'draft'
                                                ? AppColors.secondaryColor
                                                : AppColors.primaryTextColor,
                                            fontSize: 14.sp,
                                            fontFamily: AppFonts.montserrat,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(
                    () => CustomTextButton(
                      text: tkBtnPostSound.tr,
                      onPressed: controller.postMusic,
                      isLoading: controller.isLoading.value,
                      isEnabled: !controller.isLoading.value,
                      height: 60,
                      borderRadius: 100,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        mainController: controller.mainController,
      ),
    );
  }
}
