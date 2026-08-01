import 'package:get/get.dart';
import 'package:swypher_flutter/common/local/localization_service.dart';

List<LanguageModel> supportedLanguage = [
  LanguageModel('United States', 'English', 'en'),
  LanguageModel('France', 'Français', 'fr'),
];

class LocalizationViewModel extends GetxController {
  final Rx<LanguageModel> _language =
      LanguageModel('English', 'English', 'en').obs;

  LanguageModel get language => _language.value;

  LocalizationViewModel() {
    _fetchDefaultLanguage();
  }
  void _fetchDefaultLanguage() {
    final newLang = supportedLanguage.firstWhere(
        (element) => element.code == LocalizationService.savedLanguageCode,
        orElse: () => LanguageModel('United States', 'English', 'en'));
    _language.value = newLang;
    onChange(language);
  }


  void onChange(LanguageModel? value) {
    if (value != null) {
      _language.value = value;
      LocalizationService.changeLocale(value.code);
    }
  }
}

class LanguageModel {
  final String name;
  final String displayName;
  final String code;

  LanguageModel(
    this.name,
    this.displayName,
    this.code,
  );
}