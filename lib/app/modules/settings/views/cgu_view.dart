import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/settings/controllers/settings_controller.dart';
import 'package:swypher_flutter/shared/constants/constants.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';

class CguView extends GetView<SettingsController> {
  const CguView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      mainController: controller.mainController,
      showBackButton: true,
      showNavBar: false,
      showBottomListenMusic: false,
      showSettingsButton: false,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 30.h),
        children: [
          Text(
            tkCguTitle.tr,
            style: TextStyle(
              fontSize: 22.sp,
              color: AppColors.primaryTextColor,
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            tkLastUpdated.tr,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.secondaryTextColor,
              fontFamily: AppFonts.montserrat,
            ),
          ),
          SizedBox(height: 28.h),

          _Section(
            title: tkCguSection1Title.tr,
            body: tkCguSection1Body.tr,
          ),

          _Section(
            title: tkCguSection2Title.tr,
            body: tkCguSection2Body.tr,
          ),

          _Section(
            title: tkCguSection3Title.tr,
            body: tkCguSection3Body.tr,
          ),

          _Section(
            title: tkCguSection4Title.tr,
            body: tkCguSection4Body.tr,
          ),

          _Section(
            title: tkCguSection5Title.tr,
            body: tkCguSection5Body.tr,
          ),

          _Section(
            title: tkCguSection6Title.tr,
            body: tkCguSection6Body.tr,
          ),

          _Section(
            title: tkCguSection7Title.tr,
            body: tkCguSection7Body.tr,
          ),

          _Section(
            title: tkCguSection8Title.tr,
            body: tkCguSection8Body.tr,
          ),

          _Section(
            title: tkCguSection9Title.tr,
            body: tkCguSection9Body.tr,
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.primaryColor,
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.primaryTextColor,
              fontFamily: AppFonts.montserrat,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
