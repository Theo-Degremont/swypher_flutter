import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class CustomTextButton extends StatefulWidget {
  const CustomTextButton({
    super.key,
    this.onPressed,
    this.height = 70.0,
    this.primaryGradientColor,
    this.secondaryGradientColor,
    required this.text,
    this.borderRadius = 15.0,
  });

  final VoidCallback? onPressed;
  final double height;
  final Color? primaryGradientColor;
  final Color? secondaryGradientColor;
  final String text;
  final double borderRadius;

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
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
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          alignment: Alignment.center,
          height: widget.height.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius.w),
            gradient: LinearGradient(
              colors: [
                widget.primaryGradientColor ?? AppColors.primaryLinearGradientStart,
                widget.secondaryGradientColor ?? AppColors.primaryLinearGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.tertiaryColor.withValues(alpha: 0.5),
                blurRadius: 15.0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Text(
            widget.text.toUpperCase(),
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
