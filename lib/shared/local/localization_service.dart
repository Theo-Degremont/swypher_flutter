
import 'dart:ui';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/local/lang/en.dart';
import 'package:swypher_flutter/shared/local/lang/fr.dart';

import 'package:swypher_flutter/shared/services/memory_service.dart';

class LocalizationService extends Translations {
  static const fallbackLocale = Locale('en');
  static Locale? _locale = Get.deviceLocale;

  static Locale get locale {
    return _locale ?? fallbackLocale;
  }

  static String get savedLanguageCode {
    final supportedLanguages = ['en', 'fr'];

    final savedLang = MemoryService.instance.languageCode;
    if (savedLang != null && supportedLanguages.contains(savedLang)) {
      return savedLang;
    }

    final currentLocale = Get.locale?.languageCode;
    if (currentLocale != null && supportedLanguages.contains(currentLocale)) {
      return currentLocale;
    }

    return fallbackLocale.languageCode;
  }

  static init() {
    final correctedLanguageCode = savedLanguageCode;

    if (MemoryService.instance.languageCode != correctedLanguageCode) {
      MemoryService.instance.languageCode = correctedLanguageCode;
    }

    _updateLocale(correctedLanguageCode);
  }

  static _saveLocale(String languageCode) {
    MemoryService.instance.languageCode = languageCode;
  }

  static _updateLocale(String languageCode) {
    _locale = Locale(languageCode);
    Get.updateLocale(_locale!);
  }

  static changeLocale(String languageCode) {
    _updateLocale(languageCode);
    _saveLocale(languageCode);
  }

  @override
  Map<String, Map<String, String>> get keys => {
    'en': en,
    'fr': fr,
  };
}