import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_icon_button.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    this.showBackButton = false,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppColors.whiteColor.withValues(alpha: 0.1),
            width: 2.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomIconButton(
            onPressed: showBackButton ? () => Get.back() : null,
            icon: Icons.arrow_back,
            iconColor:showBackButton ? AppColors.tertiaryColor : Colors.transparent,
          ),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.primaryLinearGradientStart,
                AppColors.primaryLinearGradientEnd,
              ],
            ).createShader(bounds),
            child: Text(
              'Swypher',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.0.sp,
                fontFamily: 'Poppins',
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          CustomIconButton(
            onPressed: null,
            icon: Icons.notifications_none,
            iconColor: AppColors.tertiaryColor,
          ),
        ],
      ),
    );
  }
}


