import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile', style: TextStyle(color: AppColors.primaryTextColor)),
    );
  }
}
