import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

/// Barre de progression audio non interactive.
///
/// Affiche la position courante vs la durée totale avec un gradient et les
/// temps formatés (m:ss) à gauche et à droite.
class ProgressionBarWidget extends StatelessWidget {
  const ProgressionBarWidget({
    super.key,
    required this.position,
    required this.duration,
  });

  /// Position courante (réactive).
  final Rx<Duration> position;

  /// Durée totale (réactive).
  final Rx<Duration> duration;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pos = position.value;
      final dur = duration.value;
      final progress = dur.inMilliseconds > 0
          ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
          : 0.0;

      return Column(
        children: [
          // ── Barre ────────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fillWidth = constraints.maxWidth * progress;
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Fond
                    Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    // Remplissage gradient
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linear,
                      height: 4.h,
                      width: fillWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryLinearGradientStart,
                            AppColors.primaryLinearGradientEnd,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Temps ────────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _format(pos),
                  style: TextStyle(
                    color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                    letterSpacing: 0.5,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  _format(dur),
                  style: TextStyle(
                    color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                    letterSpacing: 0.5,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
