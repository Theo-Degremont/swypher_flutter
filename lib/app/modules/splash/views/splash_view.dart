import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/splash/controllers/splash_controller.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.only(bottom: 30.h),
        child: Stack(
          children: [
            Positioned(
              top: -150.w,
              left: -50.h,
              child: Container(
                width: 200.w,
                height: 400.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  // color: AppColors.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 120,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -150.w,
              right: -50.h,
              child: Container(
                width: 200.w,
                height: 400.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  // color: AppColors.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 120,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo_swypher.png',
                    width: 200.w,
                    height: 200.h,
                  ),
                  Text(
                    'Le prochain son commence ici'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: montserratFontFamily,
                      letterSpacing: 1.5,
                      color: AppColors.secondaryTextColor.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: SizedBox(
                      width: 180.w,
                      height: 5.h,
                      child: Stack(
                        children: [
                          // Barre fixe de fond
                          Container(
                            color: AppColors.whiteColor.withValues(alpha: 0.1),
                          ),
                          // Dégradé animé qui glisse de gauche à droite
                          AnimatedBuilder(
                            animation: controller.shimmerController,
                            builder: (context, _) {
                              final offset =
                                  (controller.shimmerController.value * 2 - 1) *
                                  180.w;
                              return Transform.translate(
                                offset: Offset(offset, 0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0x00F3778F),
                                        Color(0xFFF3778F),
                                        Color(0x00F3778F),
                                      ],
                                      stops: [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Initialisation du studio'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: montserratFontFamily,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: AppColors.secondaryTextColor.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                        child: Obx(
                          () => Text(
                            controller.dots.value,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: montserratFontFamily,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: AppColors.secondaryTextColor.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Obx(
                    () => Text(
                      controller.version.value.isEmpty
                          ? ''
                          : 'Version ${controller.version.value}'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: montserratFontFamily,
                        letterSpacing: 1.5,
                        color: AppColors.secondaryTextColor.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
