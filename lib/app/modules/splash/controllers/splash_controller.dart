import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxString dots = ''.obs;
  final RxString version = ''.obs;

  late final AnimationController shimmerController;

  Timer? _dotsTimer;

  @override
  void onInit() {
    super.onInit();
    shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _startDotsAnimation();
    _loadVersion();
    _navigateAfterDelay();
  }

  void _startDotsAnimation() {
    final sequence = ['.', '..', '...', ''];
    int index = 0;
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      dots.value = sequence[index % sequence.length];
      index++;
    });
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    version.value = info.version;
  }

  void _navigateAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(Routes.MAIN);
    });
  }

  @override
  void onClose() {
    shimmerController.dispose();
    _dotsTimer?.cancel();
    super.onClose();
  }
}
