import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class CustomBlocButton extends StatefulWidget {
  const CustomBlocButton({
    super.key,
    this.onPressed,
    required this.title,
    required this.subtitle,
    this.icon = Icons.mic_sharp,
    this.isGradient = true,});

  final VoidCallback? onPressed;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isGradient;

  @override
  State<CustomBlocButton> createState() => _CustomBlocButtonState();
}

class _CustomBlocButtonState extends State<CustomBlocButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 70.w, vertical: 40.h),
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.whiteColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            spacing: 10.h,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: widget.isGradient ? null : AppColors.quaternaryColor,
                  shape: BoxShape.circle,
                  gradient:widget.isGradient ? LinearGradient(
                    colors: [
                      AppColors.primaryLinearGradientStart,
                      AppColors.primaryLinearGradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ) : null,
                  border: widget.isGradient ? null : Border.all(
                    color: AppColors.whiteColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:widget.isGradient ?  AppColors.tertiaryColor.withValues(alpha: 0.5) : AppColors.primaryColor.withValues(alpha: 0.5),
                      blurRadius: 15.0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color:widget.isGradient ?  AppColors.secondaryColor : AppColors.primaryColor,
                  size: 30.w,
                ),
              ),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: AppColors.primaryTextColor,
                  letterSpacing: -0.5,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.secondaryTextColor,
                  letterSpacing: 0.5,

                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
