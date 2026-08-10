import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class CustomCircleIconButton extends StatefulWidget {
  const CustomCircleIconButton({
    super.key,
    this.onPressed,
    this.icon,
    this.size = 60,
    this.colorIcon,
    this.colorBackground,
    this.iconSize = 40,
  });

  final VoidCallback? onPressed;
  final IconData? icon;
  final double size;
  final Color? colorIcon;
  final Color? colorBackground;
  final double iconSize;

  @override
  State<CustomCircleIconButton> createState() => _CustomCircleIconButtonState();
}

class _CustomCircleIconButtonState extends State<CustomCircleIconButton> {
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
          width: widget.size.w,
          height: widget.size.w,
          decoration: BoxDecoration(
            color: widget.colorBackground,
            shape: BoxShape.circle,
            gradient:widget.colorBackground!=null ? null :LinearGradient(
              colors: [
                AppColors.primaryLinearGradientStart,
                AppColors.primaryLinearGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            widget.icon,
            color: widget.colorIcon ?? AppColors.secondaryColor,
            size: widget.iconSize.w,
          ),
        ),
      ),
    );
  }
}
