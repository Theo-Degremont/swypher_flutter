import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/record_music/controllers/record_music_controller.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_circle_icon_button.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_text_button.dart';
import 'package:swypher_flutter/shared/widgets/widgets/mic_button_widget.dart';
import 'package:swypher_flutter/shared/widgets/widgets/recording_visualizer_widget.dart';
import 'package:swypher_flutter/shared/widgets/widgets/topline_swypher_picker_button_widget.dart';
import 'package:swypher_flutter/shared/widgets/widgets/upload_button_widget.dart';

class RecordMusicView extends GetView<RecordMusicController> {
  const RecordMusicView({super.key});
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10.h,
                children: [
                  // ─── Topline ─────────────────────────────────────────────
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

                  // ─── Zone micro + visualiseur ─────────────────────────────
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10.h,
                      children: [
                        // Visualiseur — visible pendant l'enregistrement ET entre les pauses
                        Obx(
                          () => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: (controller.isRecording.value ||
                                    controller.bars.isNotEmpty)
                                ? RecordingVisualizerWidget(
                                    bars: controller.bars,
                                    isRecording: controller.isRecording,
                                  )
                                : SizedBox(height: 80.h),
                          ),
                        ),

                        // Bouton micro avec anneaux
                        Obx(
                          () => Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: (controller.isRecording.value
                                        ? AppColors.primaryColor
                                        : AppColors.primaryColor)
                                    .withValues(alpha: 0.2),
                                width: 2.w,
                              ),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: controller.isRecording.value
                                        ? 0.7
                                        : 0.4,
                                  ),
                                  width: 3.w,
                                ),
                              ),
                              child: MicButtonWidget(
                                size: 80,
                                iconSize: 40,
                                isRecording: controller.isRecording.value,
                                onPressed: controller.toggleRecording,
                              ),
                            ),
                          ),
                        ),

                        // ─── Sections visibles uniquement si un enregistrement existe ──
                        Obx(
                          () => controller.recordedVoice.value == null
                              ? SizedBox.shrink()
                              : Column(
                                  spacing: 10.h,
                                  children: [
                                    // Barre de progression
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 20.h,
                                        left: 20.w,
                                        right: 20.w,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.centerLeft,
                                        children: [
                                          Container(
                                            height: 4.h,
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.whiteColor.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(40.0),
                                            ),
                                          ),
                                          Container(
                                            height: 4.h,
                                            width: 100.w,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors
                                                      .primaryLinearGradientStart,
                                                  AppColors
                                                      .primaryLinearGradientEnd,
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Temps
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '0:00',
                                            style: TextStyle(
                                              color: AppColors.secondaryTextColor
                                                  .withValues(alpha: 0.6),
                                              fontSize: 12.sp,
                                              letterSpacing: 0.5,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            '0:00',
                                            style: TextStyle(
                                              color: AppColors.secondaryTextColor
                                                  .withValues(alpha: 0.6),
                                              fontSize: 12.sp,
                                              letterSpacing: 0.5,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Contrôles play / replay / supprimer
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 20.w,
                                        right: 20.w,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CustomCircleIconButton(
                                            icon: Icons.play_arrow_outlined,
                                            onPressed: () {},
                                            size: 70,
                                            iconSize: 50,
                                            colorBackground:
                                                AppColors.whiteColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            colorIcon: AppColors.primaryColor,
                                          ),
                                          CustomCircleIconButton(
                                            icon: Icons.replay_outlined,
                                            onPressed: () {},
                                            size: 70,
                                            iconSize: 50,
                                            colorBackground:
                                                AppColors.whiteColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            colorIcon: AppColors.primaryColor,
                                          ),
                                          GestureDetector(
                                            onTap: controller.deleteRecording,
                                            child: Container(
                                              width: 90.w,
                                              height: 90.w,
                                              padding: EdgeInsets.all(10.w),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color:
                                                      AppColors.tertiaryColor,
                                                  width: 1.5.w,
                                                ),
                                                color: AppColors.quinaryColor
                                                    .withValues(alpha: 0.2),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 10.h,
                                                children: [
                                                  Icon(
                                                    Icons.delete_forever_sharp,
                                                    color:
                                                        AppColors.tertiaryColor,
                                                    size: 30.w,
                                                  ),
                                                  Text(
                                                    'Supprimer'.toUpperCase(),
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.tertiaryColor,
                                                      fontSize: 10.sp,
                                                      fontFamily:
                                                          AppFonts.montserrat,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Bouton Continuer (visible uniquement si enregistrement) ──
                  Obx(
                    () => controller.recordedVoice.value == null
                        ? SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: CustomTextButton(
                              text: 'Continuer',
                              onPressed: controller.goToCompleteMusic,
                              height: 60,
                              borderRadius: 100,
                            ),
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
