import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/constants/text_keys.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_bloc_button.dart';
import '../controllers/music_studio_controller.dart';

class MusicStudioView extends GetView<MusicStudioController> {
  const MusicStudioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Text(
            tkTitleMusicStudio.tr,
            style: TextStyle(
              fontSize: 24.sp,
              color: AppColors.primaryTextColor,
              letterSpacing: -0.5,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          tkMusicStudioSubtitle.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.secondaryTextColor,
            letterSpacing: 0.5,

            fontFamily: 'Montserrat',
            fontWeight: FontWeight.normal,
          ),
        ),
        CustomBlocButton(
          title: tkMusicStudioRecord.tr,
          subtitle: tkMusicStudioRecordHint.tr,
          icon: Icons.mic_sharp,
          isGradient: true,
          onPressed: () {
            controller.goToRecordMusic();
          },
        ),
        CustomBlocButton(
          title: tkMusicStudioImport.tr,
          subtitle: tkMusicStudioImportHint.tr,
          icon: Icons.upload_file_outlined,
          isGradient: false,
          onPressed: () {
            controller.goToUploadMusic();
          },
        ),
      ],
    );
  }
}
