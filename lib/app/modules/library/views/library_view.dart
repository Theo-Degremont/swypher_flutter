import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/widgets/modals/remove_from_playlist_modal.dart';
import 'package:swypher_flutter/shared/widgets/widgets/bottom_listen_music_widget.dart';
import 'package:swypher_flutter/shared/widgets/widgets/play_button_widget.dart';
import '../controllers/library_controller.dart';

class LibraryView extends GetView<LibraryController> {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService.to;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // ─── Liste principale ────────────────────────────────────────────
          ListView(
            padding: EdgeInsets.only(top: 50.h, bottom: 120.h),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Pochette playlist ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 190.w,
                        height: 190.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryLinearGradientStart,
                              AppColors.primaryLinearGradientEnd,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.music_note_sharp,
                          color: AppColors.secondaryColor,
                          size: 70.w,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // ── Header : play button + infos ───────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Obx(
                            () => PlayButtonWidget(
                              size: 55.0,
                              iconSize: 35.0,
                              isPlaying: audio
                                  .isPlayingRx(AudioType.music)
                                  .value,
                              onPressed: controller.togglePlay,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ma Playlist',
                                style: TextStyle(
                                  fontSize: 25.sp,
                                  fontFamily: AppFonts.poppins,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryTextColor,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Row(
                                children: [
                                  Text(
                                    '${controller.likedMusics.length} Tracks',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: AppFonts.montserrat,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.secondaryTextColor,
                                    ),
                                  ),
                                  if (controller
                                      .totalDurationText
                                      .isNotEmpty) ...[
                                    SizedBox(width: 5.w),
                                    Container(
                                      width: 5.w,
                                      height: 5.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryTextColor
                                            .withValues(alpha: 0.6),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      controller.totalDurationText,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontFamily: AppFonts.montserrat,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.normal,
                                        color: AppColors.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // ── Contenu : loading / vide / liste ──────────────────
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Padding(
                        padding: EdgeInsets.only(top: 60.h),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (controller.likedMusics.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: 60.h),
                        child: Center(
                          child: Text(
                            'Aucune musique dans votre playlist pour le moment',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontFamily: AppFonts.montserrat,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryTextColor.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: controller.likedMusics
                          .asMap()
                          .entries
                          .map((e) => _TrackTile(index: e.key, ctrl: controller))
                          .toList(),
                    );
                  }),
                ],
              ),
            ],
          ),

        ],
      ),
    );
  }
}

// ─── Tuile de piste ──────────────────────────────────────────────────────────

class _TrackTile extends StatelessWidget {
  const _TrackTile({required this.index, required this.ctrl});

  final int index;
  final LibraryController ctrl;

  @override
  Widget build(BuildContext context) {

    return Obx(() {
      final isActive = ctrl.currentIndex.value == index;
      final music = ctrl.likedMusics[index];

      return GestureDetector(
        onTap: () => ctrl.playAt(index),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.whiteColor.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // ── Numéro ou equalizer animé ──────────────────────
                    SizedBox(
                      width: 24.w,
                      child: isActive
                          ? EqualizerBarsWidget(
                              isPlaying: AudioService.to
                                  .isPlayingRx(AudioType.music)
                                  .value,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: AppFonts.montserrat,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                    ),
                    SizedBox(width: 20.w),
                    // ── Titre + artiste ───────────────────────────────
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            music.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: AppFonts.montserrat,
                              letterSpacing: 0,
                              fontWeight: FontWeight.normal,
                              color: isActive
                                  ? AppColors.primaryColor
                                  : AppColors.primaryTextColor,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              Text(
                                music.beatmakerName ?? '',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: AppFonts.montserrat,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                              if (ctrl
                                      .formatDuration(music.duration)
                                      .isNotEmpty &&
                                  music.beatmakerName != null) ...[
                                SizedBox(width: 5.w),
                                Container(
                                  width: 5.w,
                                  height: 5.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryTextColor
                                        .withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                              ],
                              if (ctrl
                                  .formatDuration(music.duration)
                                  .isNotEmpty)
                                Text(
                                  ctrl.formatDuration(music.duration),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: AppFonts.montserrat,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.normal,
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => RemoveFromPlaylistModal.show(
                  music: music,
                  onConfirm: () => ctrl.removeFromLiked(music),
                ),
                child: Icon(
                  Icons.close_sharp,
                  color: AppColors.secondaryTextColor,
                  size: 24.w,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
