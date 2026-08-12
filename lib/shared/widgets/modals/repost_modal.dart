import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_text_button.dart';

class RepostModal extends StatelessWidget {
  const RepostModal({super.key, required this.musicId, required this.musicTitle});

  final String musicId;
  final String musicTitle;

  /// Affiche la modale de confirmation de repost.
  static void show({required String musicId, required String musicTitle}) {
    Get.dialog(
      RepostModal(musicId: musicId, musicTitle: musicTitle),
      barrierColor: Colors.black.withValues(alpha: 0.75),
    );
  }

  Future<void> _confirm() async {
    Get.back();
    final response = await Get.find<MusicApi>().postRepost(musicId);
    if (response.isSuccess) {
      MemoryService.instance.addRepost(musicId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(28.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.whiteColor.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.15),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Icône ──────────────────────────────────────────────────────
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLinearGradientStart.withValues(alpha: 0.2),
                    AppColors.primaryLinearGradientEnd.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppColors.primaryLinearGradientStart.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    AppColors.primaryLinearGradientStart,
                    AppColors.primaryLinearGradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Icon(Icons.repeat_sharp, size: 34.w, color: Colors.white),
              ),
            ),

            SizedBox(height: 20.h),

            // ─── Titre ──────────────────────────────────────────────────────
            Text(
              'Reposter ce mix ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 18.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),

            SizedBox(height: 12.h),

            // ─── Description ────────────────────────────────────────────────
            Text(
              'Tu t\'apprêtes à reposter "$musicTitle".\n\n'
              'Ce mix apparaîtra sur ton profil et sera visible par tes abonnés. '
              'Cette action est définitive.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryTextColor.withValues(alpha: 0.85),
                fontSize: 13.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.normal,
                height: 1.55,
                letterSpacing: 0.2,
              ),
            ),

            SizedBox(height: 28.h),

            // ─── Boutons ────────────────────────────────────────────────────
            CustomTextButton(
              text: 'Reposter',
              height: 52,
              borderRadius: 100,
              onPressed: _confirm,
            ),

            SizedBox(height: 12.h),

            GestureDetector(
              onTap: () => Get.back(),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
                  fontSize: 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
