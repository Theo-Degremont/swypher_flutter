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
    this.isLoading = false,
    this.isEnabled = true,
    this.haveBorder = false,
    this.showShadow = true,
    this.icon,
    this.iconColor,
    this.textColor,
  });

  final VoidCallback? onPressed;
  final double height;
  final Color? primaryGradientColor;
  final Color? secondaryGradientColor;
  final String text;
  final double borderRadius;
  final bool isLoading;
  final bool isEnabled;
  final bool haveBorder;
  final bool showShadow;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final canTap = widget.isEnabled && !widget.isLoading;

    return GestureDetector(
      onTapDown: canTap ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: canTap
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: canTap ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: canTap ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            alignment: Alignment.center,
            height: widget.height.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius.w),
              gradient: LinearGradient(
                colors: [
                  widget.primaryGradientColor ??
                      AppColors.primaryLinearGradientStart,
                  widget.secondaryGradientColor ??
                      AppColors.primaryLinearGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: widget.haveBorder
                  ? Border.all(color: AppColors.tertiaryColor, width: 1.5.w)
                  : null,
              boxShadow: [
                if (widget.showShadow)
                  BoxShadow(
                    color: AppColors.tertiaryColor.withValues(alpha: 0.5),
                    blurRadius: 15.0,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.secondaryColor,
                      ),
                    ),
                  )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        SizedBox(width: 16.w),
                        Icon(
                          widget.icon,
                          color: widget.iconColor ?? AppColors.secondaryColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        widget.text.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: widget.textColor ?? AppColors.secondaryColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
