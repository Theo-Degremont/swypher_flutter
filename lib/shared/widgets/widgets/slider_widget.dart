import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';

class SliderWidget extends StatelessWidget {
  const SliderWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;

  /// Value between 0.0 and 1.0
  final double value;

  final ValueChanged<double> onChanged;

  static const double _thumbDiameter = 16.0;
  static const double _trackHeight = 4.0;

  @override
  Widget build(BuildContext context) {
    return  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.montserrat,
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.montserrat,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              final thumbDiameter = _thumbDiameter.w;
              final thumbRadius = thumbDiameter / 2;
              final thumbLeft = (trackWidth * value - thumbRadius)
                  .clamp(0.0, trackWidth - thumbDiameter);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final newValue =
                      (details.localPosition.dx / trackWidth).clamp(0.0, 1.0);
                  onChanged(newValue);
                },
                onTapDown: (details) {
                  final newValue =
                      (details.localPosition.dx / trackWidth).clamp(0.0, 1.0);
                  onChanged(newValue);
                },
                child: SizedBox(
                  height: thumbDiameter,
                  width: trackWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: [
                      // Background track
                      Container(
                        height: _trackHeight.h,
                        width: trackWidth,
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),

                      // Gradient progress fill
                      Container(
                        height: _trackHeight.h,
                        width: trackWidth * value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryLinearGradientStart,
                              AppColors.primaryLinearGradientEnd,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),

                      // Thumb
                      Positioned(
                        left: thumbLeft,
                        top: 0,
                        child: Container(
                          width: thumbDiameter,
                          height: thumbDiameter,
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
                                color: AppColors.primaryColor
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      
    );
  }
}
