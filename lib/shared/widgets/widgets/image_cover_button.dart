import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';

class ImageCoverButton extends StatefulWidget {
  const ImageCoverButton({
    super.key,
    required this.onTap,
    this.imageFile,
    this.height,
  });

  final VoidCallback onTap;
  final File? imageFile;
  final double? height;

  @override
  State<ImageCoverButton> createState() => _ImageCoverButtonState();
}

class _ImageCoverButtonState extends State<ImageCoverButton> {
  bool _isPressed = false;

  double get _height => widget.height ?? 300.h;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
          height: _height,
          width: double.infinity,
          child: widget.imageFile != null
              ? _buildImagePreview()
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.file(
        widget.imageFile!,
        height: _height,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.whiteColor.withValues(alpha: 0.3),
        strokeWidth: 2.0,
        dash: 8.0,
        gap: 5.0,
        borderRadius: 10.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backgroundImageButton),
            opacity: 0.2,
            fit: BoxFit.cover,
          ),
          color: AppColors.whiteColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primaryColor,
              size: 40.w,
            ),
            SizedBox(height: 10.h),
            Text(
              'Ajouter une image de couverture',
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 16.sp,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Format carré (jpg, png)',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14.sp,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
    required this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            strokeWidth / 2,
            strokeWidth / 2,
            size.width - strokeWidth,
            size.height - strokeWidth,
          ),
          Radius.circular(borderRadius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      bool drawing = true;
      while (distance < metric.length) {
        final segmentEnd = (distance + (drawing ? dash : gap))
            .clamp(0.0, metric.length);
        if (drawing) {
          canvas.drawPath(metric.extractPath(distance, segmentEnd), paint);
        }
        distance = segmentEnd;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap ||
      old.borderRadius != borderRadius;
}
