import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/constants/text_keys.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_text_button.dart';

class DeleteMusicModal extends StatelessWidget {
  const DeleteMusicModal({
    super.key,
    required this.music,
    required this.onConfirm,
  });

  final MusicModel music;
  final Future<void> Function() onConfirm;

  static void show({
    required MusicModel music,
    required Future<void> Function() onConfirm,
  }) {
    Get.dialog(
      DeleteMusicModal(music: music, onConfirm: onConfirm),
      barrierColor: Colors.black.withValues(alpha: 0.75),
    );
  }

  Future<void> _confirm() async {
    Get.back();
    await onConfirm();
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
                child: Icon(Icons.delete_outline_sharp, size: 34.w, color: Colors.white),
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              tkModalDeleteMusicTitle.tr,
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

            Text(
              tkModalDeleteMusicBody.trParams({'title': music.title}),
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

            CustomTextButton(
              text: tkModalDeleteMusicBtn.tr,
              height: 52,
              borderRadius: 100,
              onPressed: _confirm,
            ),

            SizedBox(height: 12.h),

            GestureDetector(
              onTap: () => Get.back(),
              child: Text(
                tkBtnCancel.tr,
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
