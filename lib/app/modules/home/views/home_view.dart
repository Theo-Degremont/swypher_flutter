import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/widgets/widgets/music_card_widget.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => controller.selectTab(0),
                child: Obx(() {
                  final selected = controller.selectedTab.value == 0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Auto'.toUpperCase(),
                        style: TextStyle(
                          color: selected
                              ? AppColors.primaryColor
                              : AppColors.secondaryTextColor,
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (selected) ...[
                        SizedBox(height: 4.h),
                        Container(
                          width: 40.w,
                          height: 3.h,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ],
                  );
                }),
              ),
              SizedBox(width: 20.w),
              GestureDetector(
                onTap: () => controller.selectTab(1),
                child: Obx(() {
                  final selected = controller.selectedTab.value == 1;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Prods'.toUpperCase(),
                        style: TextStyle(
                          color: selected
                              ? AppColors.primaryColor
                              : AppColors.secondaryTextColor,
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (selected) ...[
                        SizedBox(height: 4.h),
                        Container(
                          width: 50.w,
                          height: 3.h,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 9,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: 5,
            itemBuilder: (context, index) {
              return MusicCardWidget(
                id: index,
                songTitle: 'Song Title ${index + 1}',
                artistName: 'Artist Name',
                prodArtistName: 'Prod.Artist Name',
                timeStamp: '1:30',
                totalTime: '3:45',
              );
            },
          ),
        ),
      ],
    );
  }
}
