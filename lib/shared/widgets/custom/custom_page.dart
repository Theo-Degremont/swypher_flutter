import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_app_bar.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_nav_bar.dart';

class CustomPage extends StatelessWidget {
  const CustomPage({
    super.key,
    this.showBackButton = false,
    this.showNavBar = true,
    required this.body,
    required this.mainController,
    });

  final bool showBackButton;
  final bool showNavBar;
  final Widget body;
  final MainController mainController;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(children: [
        Expanded(
          flex: 12,
          child: CustomAppBar(
            showBackButton: showBackButton,
          ),
        ),
        Expanded(
          flex: showNavBar ? 78 : 88,
          child: body,
        ),
      if (showNavBar)
      Expanded(
          flex: 10,
          child: Obx(
            () => CustomNavBar(
              currentIndex: mainController.currentIndex.value,
              navBarColor: mainController.navBarColor.value,
              onTabSelected: mainController.changePage,
            ),
          ),
        ),
      ],)
    );
  }
}