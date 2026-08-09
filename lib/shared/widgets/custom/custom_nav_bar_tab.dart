import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';

class CustomNavBarTab extends StatefulWidget {
  const CustomNavBarTab({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  State<CustomNavBarTab> createState() => _CustomNavBarTabState();
}

class _CustomNavBarTabState extends State<CustomNavBarTab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? AppColors.primaryColor
        : AppColors.secondaryTextColor.withValues(alpha: 0.6);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: color,
                size: 24.w,
              ),
              SizedBox(height: 4.h),
              Text(
                widget.label,
                style: TextStyle(
                  color: color,
                  fontSize: 12.sp,
                  letterSpacing: 0.6,
                  fontFamily: AppFonts.poppins,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
