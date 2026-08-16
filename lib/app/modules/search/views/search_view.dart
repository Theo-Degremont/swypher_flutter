import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_tab_bar.dart';
import 'package:swypher_flutter/shared/widgets/widgets/bottom_listen_music_widget.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.h, bottom: 4.h),
              child: ValueListenableBuilder<bool>(
                valueListenable: controller.searchFocused,
                builder: (context, focused, _) => TextField(
                  controller: controller.searchCtrl,
                  focusNode: controller.searchFocus,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.secondaryTextColor,
                    letterSpacing: 0.5,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                    hintText: tkSearchHint.tr,
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.secondaryTextColor.withValues(alpha: 0.3),
                      letterSpacing: 0.5,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: Icon(
                      Icons.search_sharp,
                      color: focused
                          ? AppColors.primaryColor
                          : AppColors.secondaryTextColor.withValues(alpha: 0.3),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.whiteColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Obx(() {
                // État initial : champ vide
                if (controller.query.value.isEmpty) {
                  return controller.memory.searchHistoryObs.isEmpty
                      ? _EmptyState()
                      : _SearchHistoryState();
                }

                // Chargement
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 2,
                    ),
                  );
                }

                // Aucun résultat
                if (controller.hasSearched.value &&
                    controller.musicResults.isEmpty &&
                    controller.toplineResults.isEmpty) {
                  return _NoResultState();
                }

                // Résultats disponibles
                if (controller.hasSearched.value) {
                  return Column(
                    children: [
                      SizedBox(height: 20.h),
                      Center(
                        child: Obx(() => CustomTabBar(
                          tabs: [tkTabMusic.tr, tkTabTopline.tr],
                          selectedIndex: controller.selectedTab.value,
                          onTap: controller.selectTab,
                          spacing: 24,
                          fontSize: 12,
                        )),
                      ),
                      SizedBox(height: 8.h),
                      Expanded(
                        child: Obx(() {
                          final list = controller.selectedTab.value == 0
                              ? controller.musicResults
                              : controller.toplineResults;

                          if (list.isEmpty) {
                            return Center(
                              child: Text(
                                tkSearchNoResultCategory.tr,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.secondaryTextColor
                                      .withValues(alpha: 0.5),
                                  fontFamily: AppFonts.montserrat,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.only(
                              top: 8.h,
                              bottom: 120.h,
                            ),
                            itemCount: list.length,
                            itemBuilder: (context, index) => _TrackTile(
                              index: index,
                              ctrl: controller,
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
          ],
        ),
      ),
    );
  }
}
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.travel_explore_sharp,
            size: 60.sp,
            color: AppColors.primaryColor.withValues(alpha: 0.35),
          ),
          SizedBox(height: 16.h),
          Text(
            tkSearchDiscoverSounds.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.primaryTextColor.withValues(alpha: 0.7),
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            tkSearchDiscoverHint.tr,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.secondaryTextColor.withValues(alpha: 0.5),
              fontFamily: AppFonts.montserrat,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHistoryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SearchController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tkSearchRecent.tr,
              style: TextStyle(
                fontSize: 22.sp,
                color: AppColors.primaryTextColor,
                fontFamily: AppFonts.poppins,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: controller.clearAllHistory,
              behavior: HitTestBehavior.opaque,
              child: Text(
                tkSearchClearAll.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.tertiaryColor,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: Obx(() {
            final history = controller.memory.searchHistoryObs;
            return ListView.builder(
              padding: EdgeInsets.only(bottom: 120.h),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final title = history[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.history,
                          size: 20.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        flex: 8,
                        child: Text(
                          title,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.secondaryTextColor,
                            fontFamily: AppFonts.montserrat,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => controller.removeHistoryEntry(title),
                          behavior: HitTestBehavior.opaque,
                          child: Icon(
                            Icons.close,
                            size: 20.sp,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _NoResultState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_sharp,
            size: 60.sp,
            color: AppColors.secondaryTextColor.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            tkSearchNoResult.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.primaryTextColor.withValues(alpha: 0.7),
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            tkSearchNoResultHint.tr,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.secondaryTextColor.withValues(alpha: 0.5),
              fontFamily: AppFonts.montserrat,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tuile de piste ───────────────────────────────────────────────────────────

class _TrackTile extends StatelessWidget {
  const _TrackTile({required this.index, required this.ctrl});

  final int index;
  final SearchController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = ctrl.selectedTab.value == 0
          ? ctrl.musicResults
          : ctrl.toplineResults;

      if (index >= list.length) return const SizedBox.shrink();

      final music    = list[index];
      final isActive = ctrl.currentIndex.value == index;

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
              // ── Numéro ou equalizer animé ──────────────────────────────
              SizedBox(
                width: 24.w,
                child: isActive
                    ? EqualizerBarsWidget(
                        isPlaying:
                            AudioService.to.isPlayingRx(AudioType.music).value,
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
              // ── Titre + artiste ────────────────────────────────────────
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
                        if (music.beatmakerName != null)
                          Text(
                            music.beatmakerName!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppFonts.montserrat,
                              letterSpacing: 1,
                              fontWeight: FontWeight.normal,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        if (ctrl.formatDuration(music.duration).isNotEmpty &&
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
                        if (ctrl.formatDuration(music.duration).isNotEmpty)
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
      );
    });
  }
}
