import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class MicButtonWidget extends StatefulWidget {
  const MicButtonWidget({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  State<MicButtonWidget> createState() => _MicButtonWidgetState();
}

class _MicButtonWidgetState extends State<MicButtonWidget> {
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
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLinearGradientStart,
                AppColors.primaryLinearGradientEnd,
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
          child: Icon(Icons.mic_sharp, color: AppColors.secondaryColor, size: 30.w),
        ),
      ),
    );
  }
}