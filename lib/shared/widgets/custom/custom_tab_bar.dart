import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/constants/fonts.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
    this.expanded = false,
    this.flexValues,
    this.spacing = 20.0,
    this.fontSize = 12.0,
    this.indicatorWidth,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final List<String> tabs;
  final int selectedIndex;
  final void Function(int index) onTap;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool expanded;
  final List<int>? flexValues;
  final double spacing;
  final double fontSize;
  final double? indicatorWidth;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final active   = activeColor   ?? AppColors.primaryColor;
    final inactive = inactiveColor ?? AppColors.secondaryTextColor;

    final items = tabs.asMap().entries.map((e) {
      final index    = e.key;
      final label    = e.value;
      final selected = index == selectedIndex;

      final tab = GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: _TabItem(
          label: label,
          selected: selected,
          activeColor: active,
          inactiveColor: inactive,
          fontSize: fontSize,
          indicatorWidth: indicatorWidth,
        ),
      );

      if (expanded) {
        final flex = (flexValues != null && index < flexValues!.length)
            ? flexValues![index]
            : 1;
        return Expanded(flex: flex, child: tab) as Widget;
      }
      return tab;
    }).toList();

    if (expanded) {
      return Row(mainAxisSize: MainAxisSize.max, children: items);
    }

    final spaced = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i < items.length - 1) spaced.add(SizedBox(width: spacing.w));
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: spaced,
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.fontSize,
    this.indicatorWidth,
  });

  final String label;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final double fontSize;
  final double? indicatorWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? activeColor : inactiveColor,
            fontSize: fontSize.sp,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        if (selected) ...[
          SizedBox(height: 4.h),
          Container(
            width: indicatorWidth?.w,
            height: 3.h,
            color: activeColor,
          ),
        ],
      ],
    );
  }
}
