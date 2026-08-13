import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_nav_bar_tab.dart';
import 'package:swypher_flutter/shared/widgets/widgets/mic_button_widget.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int>? onTabSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiaryColor.withValues(alpha: 0.1),
            blurRadius: 20.0,
            offset: const Offset(0, -4),
          ),
        ],
        color: AppColors.backgroundColor.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.whiteColor.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomNavBarTab(
            icon: Icons.home_sharp,
            label: 'Home',
            isSelected: currentIndex == 0,
            onPressed: () => onTabSelected?.call(0),
          ),
          CustomNavBarTab(
            icon: Icons.search_sharp,
            label: 'Search',
            isSelected: currentIndex == 1,
            onPressed: () => onTabSelected?.call(1),
          ),
          Transform.translate(
            offset: const Offset(0, -20),
            child: MicButtonWidget(
              onPressed: () => onTabSelected?.call(4),
            ),
          ),
          CustomNavBarTab(
            icon: Icons.library_music_rounded,
            label: 'Playlist',
            isSelected: currentIndex == 2,
            onPressed: () => onTabSelected?.call(2),
          ),
          CustomNavBarTab(
            icon: Icons.person_outline_sharp,
            label: 'Profile',
            isSelected: currentIndex == 3,
            onPressed: () => onTabSelected?.call(3),
          ),
        ],
      ),
    );
  }
}
