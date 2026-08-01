import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:swypher_flutter/common/services/memory_service.dart';
// import 'package:sifflard_flutter/common/services/audio_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> configureApp() async {

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await WakelockPlus.enable();
  await GetStorage.init();
  await MemoryService.instance.ensureInitialized();
  Get.put(MemoryService.instance);
  // await AudioService.initialize();

  final supportedLanguages = ['en', 'fr'];

  if (MemoryService.instance.languageCode == null) {
    final deviceLanguage = Get.deviceLocale?.languageCode ?? 'en';
    if (supportedLanguages.contains(deviceLanguage)) {
      MemoryService.instance.languageCode = deviceLanguage;
    } else {
      MemoryService.instance.languageCode = 'en';
    }
  }
}