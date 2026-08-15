import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/constants/fonts.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_icon_button.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_tab_bar.dart';
import 'package:swypher_flutter/shared/widgets/modals/delete_music_modal.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_text_button.dart';
import 'package:swypher_flutter/shared/widgets/widgets/bottom_listen_music_widget.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(top: 30.h, bottom: 100.h),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final avatarUrl = controller.resolveAvatarUrl(
                      controller.memory.currentUser?.profilePicture,
                    );
                    return Container(
                      width: 100.w,
                      height: 100.w,
                      padding: EdgeInsets.all(3),
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
                      ),
                      child: ClipOval(
                        child: avatarUrl != null
                            ? Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _defaultAvatar(),
                              )
                            : _defaultAvatar(),
                      ),
                    );
                  }),

                  SizedBox(height: 16.h),

                  Obx(() {
                    final user = controller.memory.currentUser;
                    return Text(
                      user?.stageName ?? user?.pseudo ?? 'Stage Name',
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryTextColor,
                        fontFamily: AppFonts.poppins,
                      ),
                    );
                  }),

                  SizedBox(height: 10.h),

                  Obx(() {
                    final pseudo = controller.memory.currentUser?.pseudo;
                    return Text(
                      pseudo != null ? '@$pseudo' : '@pseudo',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.normal,
                        color: AppColors.secondaryTextColor,
                        fontFamily: AppFonts.montserrat,
                      ),
                    );
                  }),

                  SizedBox(height: 10.h),

                  CustomTextButton(
                    text: 'Modifier mon profil',
                    onPressed: () {},
                    height: 40.h,
                  ),

                  SizedBox(height: 10.h),

                  Obx(() {
                    final desc = controller.memory.currentUser?.description;
                    if (desc == null || desc.isEmpty)
                      return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Text(
                        desc,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                          color: AppColors.secondaryTextColor,
                          fontFamily: AppFonts.montserrat,
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: 10.h),

                  // ── Stats ─────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 5.h),
                          Obx(
                            () => Text(
                              '${controller.publishedMusics.length}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.tertiaryColor,
                                fontFamily: AppFonts.montserrat,
                              ),
                            ),
                          ),
                          Text(
                            'Posts',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.normal,
                              color: AppColors.secondaryTextColor,
                              fontFamily: AppFonts.montserrat,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  Obx(
                    () => CustomTabBar(
                      tabs: const [
                        'Musiques',
                        'Prods',
                        'Republication',
                        'Brouillon',
                      ],
                      selectedIndex: controller.selectedTab.value,
                      onTap: controller.selectTab,
                      activeColor: AppColors.tertiaryColor,
                      fontSize: 10,
                      expanded: true,
                      flexValues: const [2, 2, 3, 2],
                    ),
                  ),

                  Container(
                    height: 1.h,
                    color: AppColors.secondaryTextColor.withValues(alpha: 0.2),
                  ),

                  SizedBox(height: 10.h),

                  Obx(() {
                    if (controller.isLoading.value) {
                      return Padding(
                        padding: EdgeInsets.only(top: 60.h),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    final list = controller.activeList;

                    if (list.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: 60.h),
                        child: Center(
                          child: Text(
                            'Aucun contenu pour le moment',
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
                      children: list
                          .asMap()
                          .entries
                          .map(
                            (e) => _TrackTile(index: e.key, ctrl: controller),
                          )
                          .toList(),
                    );
                  }),
                ],
              ),
            ],
          ),

          Obx(() {
            final idx = controller.currentIndex.value;
            if (idx < 0 || idx >= controller.activeList.length)
              return const SizedBox.shrink();
            final music = controller.activeList[idx];
            return BottomListenMusicWidget(
              music: music,
              coverUrl: controller.resolveCoverUrl(music.coverImage),
              onTogglePlay: controller.togglePlay,
              formatDuration: controller.formatDuration,
            );
          }),
        ],
      ),
    );
  }

  Widget _defaultAvatar() => Container(
    color: AppColors.primaryLinearGradientStart.withValues(alpha: 0.3),
    child: Icon(
      Icons.person_sharp,
      size: 50.sp,
      color: AppColors.secondaryColor,
    ),
  );
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({required this.index, required this.ctrl});

  final int index;
  final ProfileController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = ctrl.currentIndex.value == index;
      final list = ctrl.activeList;
      if (index >= list.length) return const SizedBox.shrink();
      final music = list[index];

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
                                  (music.beatmakerName ?? '').isNotEmpty) ...[
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
              if (ctrl.selectedTab.value != 2)
                CustomIconButton(
                  onPressed: () => DeleteMusicModal.show(
                    music: music,
                    onConfirm: () => ctrl.deleteMusic(music),
                  ),
                  iconColor: AppColors.secondaryTextColor,
                  iconSize: 24.w,
                  icon: Icons.delete_outline_sharp,
                ),
            ],
          ),
        ),
      );
    });
  }
}
