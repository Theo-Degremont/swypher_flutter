import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';

class CustomField extends StatelessWidget {
  const CustomField({
    super.key,
    required this.focusNode,
    required this.isFocused,
    this.controller,
    this.height = 110.0,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.errorText,
    this.marginBottom = 10.0,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.obscureText = false,
    this.showEyeIcon = false,
    this.onTapEye,
  });

  final FocusNode focusNode;
  final ValueNotifier<bool> isFocused;
  final TextEditingController? controller;
  final double height;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final String? errorText;
  final double marginBottom;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final bool obscureText;
  final bool showEyeIcon;
  final VoidCallback? onTapEye;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom.h),
      height: height.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Text(
              labelText,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.secondaryTextColor,
                letterSpacing: 0.5,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isFocused,
            builder: (context, isFocused, _) {
              return TextField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                onSubmitted: (_) => onSubmitted?.call(),
                focusNode: focusNode,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.secondaryTextColor,
                  letterSpacing: 0.5,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.secondaryTextColor.withValues(alpha: 0.3),
                    letterSpacing: 0.5,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.normal,
                  ),
                  suffixIcon: showEyeIcon
                      ? IconButton(
                          icon: obscureText
                              ? Icon(Icons.visibility_outlined)
                              : Icon(Icons.visibility_off_outlined),
                          color: isFocused
                              ? AppColors.primaryColor
                              : AppColors.secondaryTextColor.withValues(
                                  alpha: 0.3,
                                ),
                          onPressed: onTapEye,
                        )
                      : null,
                  prefixIcon: prefixIcon != null
                      ? Icon(
                          prefixIcon,
                          color: isFocused
                              ? AppColors.primaryColor
                              : AppColors.secondaryTextColor.withValues(
                                  alpha: 0.3,
                                ),
                        )
                      : null,
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
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Text(
              errorText ?? 'none',
              style: TextStyle(
                fontSize: 12.sp,
                color: errorText != null
                    ? AppColors.primaryColor
                    : Colors.transparent,
                letterSpacing: 0.5,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
