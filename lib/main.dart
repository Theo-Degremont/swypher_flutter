import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:swypher_flutter/common/local/localization_service.dart';
import 'package:swypher_flutter/common/services/memory_service.dart';
import 'package:swypher_flutter/core/app_config.dart';

import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureApp();
  runApp(
    GetMaterialApp(
      title: "Swypher",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      debugShowCheckedModeBanner: false,
      translations: LocalizationService(),
      locale: Locale(MemoryService.instance.languageCode!),
      fallbackLocale: LocalizationService.fallbackLocale,
    ),
  );
}
