import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import '../controllers/library_controller.dart';

class LibraryBody extends GetView<LibraryController> {
  const LibraryBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Library', style: TextStyle(color: AppColors.primaryTextColor)),
    );
  }
}
