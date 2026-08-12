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
    this.fontFamilyLabel = AppFonts.montserrat,
    this.textColorLabel,
    this.fontSizeLabel = 12.0,
    this.fontWeightLabel = FontWeight.bold,
    this.isExpandable = false,
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
  final String fontFamilyLabel;
  final Color? textColorLabel;
  final double fontSizeLabel;
  final FontWeight fontWeightLabel;
  final bool isExpandable;

  Widget _buildTextField(bool isFocused) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: isExpandable ? TextInputType.multiline : keyboardType,
      textInputAction: isExpandable ? TextInputAction.newline : textInputAction,
      onSubmitted: (_) => onSubmitted?.call(),
      focusNode: focusNode,
      maxLines: isExpandable ? null : 1,
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
                    : AppColors.secondaryTextColor.withValues(alpha: 0.3),
                onPressed: onTapEye,
              )
            : null,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: isFocused
                    ? AppColors.primaryColor
                    : AppColors.secondaryTextColor.withValues(alpha: 0.3),
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
  }

  @override
  Widget build(BuildContext context) {
    final label = Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: Text(
        labelText,
        style: TextStyle(
          fontSize: fontSizeLabel.sp,
          color: textColorLabel ?? AppColors.secondaryTextColor,
          letterSpacing: 0.5,
          fontFamily: fontFamilyLabel,
          fontWeight: fontWeightLabel,
        ),
      ),
    );

    final error = Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: Text(
        errorText ?? 'none',
        style: TextStyle(
          fontSize: 12.sp,
          color: errorText != null ? AppColors.primaryColor : Colors.transparent,
          letterSpacing: 0.5,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (isExpandable) {
      return Container(
        margin: EdgeInsets.only(bottom: marginBottom.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label,
            SizedBox(height: 8.h),
            ValueListenableBuilder<bool>(
              valueListenable: isFocused,
              builder: (context, focused, _) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 240.h),
                  child: _buildTextField(focused),
                );
              },
            ),
            SizedBox(height: 4.h),
            error,
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: marginBottom.h),
      height: height.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          ValueListenableBuilder<bool>(
            valueListenable: isFocused,
            builder: (context, focused, _) => _buildTextField(focused),
          ),
          error,
        ],
      ),
    );
  }
}
