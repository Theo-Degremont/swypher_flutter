import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class ToplineSwypherPickerButtonWidget extends StatefulWidget {
  const ToplineSwypherPickerButtonWidget({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  State<ToplineSwypherPickerButtonWidget> createState() => _ToplineSwypherPickerButtonWidgetState();
}

class _ToplineSwypherPickerButtonWidgetState extends State<ToplineSwypherPickerButtonWidget> {
  bool _isPressed = false;

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
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.whiteColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.quinaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.library_music_outlined,
                  color: AppColors.tertiaryColor,
                  size: 30.w,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choisir dans Swypher',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.primaryTextColor,
                              letterSpacing: 0.5,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Accéder au contenu de la communauté',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.secondaryTextColor,
                              letterSpacing: 0.5,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}