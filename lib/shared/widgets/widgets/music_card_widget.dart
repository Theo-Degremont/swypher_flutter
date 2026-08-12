import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_icon_button.dart';
import 'package:swypher_flutter/shared/widgets/modals/repost_modal.dart';
import 'package:swypher_flutter/shared/widgets/widgets/play_button_widget.dart';
import 'package:swypher_flutter/shared/widgets/widgets/progression_bar_widget.dart';

class MusicCardWidget extends StatelessWidget {
  const MusicCardWidget({super.key, required this.music});

  final MusicModel music;

  @override
  Widget build(BuildContext context) {
    final audio    = AudioService.to;
    final homeCtrl = Get.find<HomeController>();
    final memory   = MemoryService.instance;

    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 35.h),
      height: 560.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          // ─── Pochette ───────────────────────────────────────────────────────
          Container(
            width: 280.w,
            height: 280.w,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withValues(alpha: 0.5),
                  blurRadius: 15.0,
                  offset: const Offset(0, 0),
                ),
              ],
              gradient: RadialGradient(
                stops: const [0.0, 1.0],
                colors: [const Color(0xFF0A0A0A), AppColors.blackColor],
                center: Alignment.center,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF31253E), width: 5.0),
            ),
            child: Container(
              margin: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.whiteColor.withValues(alpha: 0.1),
                  width: 1.0,
                ),
              ),
              child: Container(
                margin: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.whiteColor.withValues(alpha: 0.1),
                    width: 1.0,
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.whiteColor.withValues(alpha: 0.1),
                      width: 1.0,
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.whiteColor.withValues(alpha: 0.1),
                        width: 1.0,
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.whiteColor.withValues(alpha: 0.1),
                          width: 1.0,
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.whiteColor.withValues(alpha: 0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.whiteColor.withValues(alpha: 0.1),
                              width: 1.0,
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(5.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.whiteColor.withValues(alpha: 0.1),
                                width: 1.0,
                              ),
                            ),
                            child: Container(
                              margin: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.whiteColor.withValues(alpha: 0.1),
                                  width: 1.0,
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.whiteColor.withValues(alpha: 0.1),
                                    width: 1.0,
                                  ),
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryLinearGradientStart,
                                        AppColors.primaryLinearGradientEnd,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFF31253E),
                                      width: 5.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // ─── Titre ─────────────────────────────────────────────────────────
          Text(
            music.title,
            style: TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 24.sp,
              letterSpacing: -0.5,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8.h),

          // ─── Artiste ───────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                music.beatmakerName ?? 'Artiste',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14.sp,
                  letterSpacing: 0.5,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 5.w),
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                'Prod. ${music.beatmakerName ?? 'Artiste'}',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 14.sp,
                  letterSpacing: 0.5,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ─── Barre de progression ───────────────────────────────────────────
          ProgressionBarWidget(
            position: audio.positionRx(AudioType.music),
            duration: audio.durationRx(AudioType.music),
          ),

          SizedBox(height: 16.h),

          // ─── Boutons ────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                final isReposted = memory.musicRepostedObs.contains(music.id);
                return Opacity(
                  opacity: isReposted ? 0.3 : 1.0,
                  child: CustomIconButton(
                    onPressed: isReposted
                        ? null
                        : () => RepostModal.show(
                              musicId: music.id,
                              musicTitle: music.title,
                            ),
                    icon: Icons.repeat_sharp,
                    iconColor: isReposted
                        ? AppColors.primaryColor
                        : AppColors.secondaryTextColor,
                  ),
                );
              }),
              Obx(() {
                final isLiked = memory.musicLikedObs.contains(music.id);
                return CustomIconButton(
                  onPressed: () => memory.toggleLike(music.id),
                  icon: isLiked ? Icons.favorite_sharp : Icons.favorite_border_sharp,
                  iconColor: isLiked ? AppColors.primaryColor : AppColors.secondaryTextColor,
                );
              }),
              Obx(() => PlayButtonWidget(
                    isPlaying: audio.isPlayingRx(AudioType.music).value,
                    onPressed: homeCtrl.togglePlay,
                  )),
              CustomIconButton(
                onPressed: () {},
                icon: Icons.chat_bubble_outline_sharp,
                iconColor: AppColors.secondaryTextColor,
              ),
              CustomIconButton(
                onPressed: () {},
                icon: Icons.share_sharp,
                iconColor: AppColors.secondaryTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
