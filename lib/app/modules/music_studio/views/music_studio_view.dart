import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import '../controllers/music_studio_controller.dart';

class MusicStudioView extends GetView<MusicStudioController> {
  const MusicStudioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Music Studio', style: TextStyle(color: AppColors.primaryTextColor)),
    );
  }
}
