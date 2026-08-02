import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:swypher_flutter/shared/widgets/custom/custom_page.dart';

import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPage();
  }
}
