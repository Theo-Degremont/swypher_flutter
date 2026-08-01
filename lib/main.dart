import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:swypher_flutter/common/local/localization_service.dart';
import 'package:swypher_flutter/common/services/memory_service.dart';
import 'package:swypher_flutter/core/app_config.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureApp();
  runApp(
    ScreenUtilInit(
      designSize: const Size(393, 852), // iPhone 16
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        title: "Swypher",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        theme: ThemeData(scaffoldBackgroundColor: AppColors.backgroundColor),
        debugShowCheckedModeBanner: false,
        translations: LocalizationService(),
        locale: Locale(MemoryService.instance.languageCode!),
        fallbackLocale: LocalizationService.fallbackLocale,
      ),
    ),
  );
}
