import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class RecordingVisualizerWidget extends StatelessWidget {
  const RecordingVisualizerWidget({
    super.key,
    required this.bars,
    required this.isRecording,
  });

  /// Barres accumulées depuis le controller (persist entre pause et reprise).
  final RxList<double> bars;

  /// Indique si l'enregistrement est actif (affiche le curseur + les points).
  final RxBool isRecording;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 80.h,
        width: double.infinity,
        child: CustomPaint(
          painter: _WaveformPainter(
            bars: List.unmodifiable(bars),
            showCursor: isRecording.value,
            gradientStart: AppColors.primaryLinearGradientStart,
            gradientEnd: AppColors.primaryLinearGradientEnd,
            cursorColor: AppColors.primaryColor,
            dotColor: AppColors.whiteColor.withValues(alpha: 0.25),
          ),
        ),
      );
    });
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.bars,
    required this.showCursor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.cursorColor,
    required this.dotColor,
  });

  final List<double> bars;
  final bool showCursor;
  final Color gradientStart;
  final Color gradientEnd;
  final Color cursorColor;
  final Color dotColor;

  static const double _barWidth = 4.0;
  static const double _barGap = 5.0;
  static const double _barStep = _barWidth + _barGap;
  static const double _minBarHeight = 4.0;
  static const double _dotRadius = 2.5;
  static const double _cursorDotRadius = 5.0;
  static const double _cursorLineWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // ── Barres (gauche du curseur, la plus récente collée au curseur) ─────────
    for (int i = 0; i < bars.length; i++) {
      final x = centerX - _barStep * (i + 1);
      if (x - _barWidth / 2 < 0) break;

      final amp = bars[bars.length - 1 - i];
      final barHeight = (_minBarHeight + amp * (size.height - _minBarHeight))
          .clamp(_minBarHeight, size.height);

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, centerY),
          width: _barWidth,
          height: barHeight,
        ),
        const Radius.circular(_barWidth / 2),
      );

      final barPaint = Paint()
        ..shader = LinearGradient(
          colors: [gradientEnd, gradientStart],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(
          Rect.fromCenter(
            center: Offset(x, centerY),
            width: _barWidth,
            height: size.height,
          ),
        );

      canvas.drawRRect(rect, barPaint);
    }

    // ── Curseur + points droite (visibles uniquement pendant l'enregistrement) ─
    if (showCursor) {
      // Ligne verticale
      final cursorLinePaint = Paint()
        ..color = cursorColor
        ..strokeWidth = _cursorLineWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(centerX, _cursorDotRadius * 2),
        Offset(centerX, size.height - _cursorDotRadius * 2),
        cursorLinePaint,
      );

      // Dots en haut et en bas
      final cursorDotPaint = Paint()..color = cursorColor;
      canvas.drawCircle(
        Offset(centerX, _cursorDotRadius),
        _cursorDotRadius,
        cursorDotPaint,
      );
      canvas.drawCircle(
        Offset(centerX, size.height - _cursorDotRadius),
        _cursorDotRadius,
        cursorDotPaint,
      );

      // Points à droite (temps non encore enregistré)
      final dotPaint = Paint()..color = dotColor;
      double dotX = centerX + _barStep;
      while (dotX + _dotRadius <= size.width) {
        canvas.drawCircle(Offset(dotX, centerY), _dotRadius, dotPaint);
        dotX += _barStep;
      }
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.bars.length != bars.length ||
      oldDelegate.showCursor != showCursor;
}
