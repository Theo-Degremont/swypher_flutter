import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class PlayButtonWidget extends StatefulWidget {
  const PlayButtonWidget({
    super.key,
    this.onPressed,
    this.size = 70.0,
    this.iconSize = 40.0,
    this.isPlaying = false,
  });

  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final bool isPlaying;

  @override
  State<PlayButtonWidget> createState() => _PlayButtonWidgetState();
}

class _PlayButtonWidgetState extends State<PlayButtonWidget> {
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
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLinearGradientStart,
                AppColors.primaryLinearGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_sharp,
              key: ValueKey(widget.isPlaying),
              color: AppColors.secondaryColor,
              size: widget.iconSize.w,
            ),
          ),
        ),
      ),
    );
  }
}
