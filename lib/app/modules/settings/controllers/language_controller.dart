import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocaleOption {
  final String displayName;
  final String languageCode;
  final String countryCode;
  final String flagAsset;

  const LocaleOption({
    required this.displayName,
    required this.languageCode,
    required this.countryCode,
    required this.flagAsset,
  });

  Locale get locale => Locale(languageCode, countryCode);
}

class LanguageController extends GetxController {
  final _storage = GetStorage();
  final currentLocale = const Locale('en', 'US').obs;

  final supportedLocales = const [
    LocaleOption(
      displayName: 'English',
      languageCode: 'en',
      countryCode: 'US',
      flagAsset: 'assets/flags/en.png',
    ),
    LocaleOption(
      displayName: 'ភាសាខ្មែរ',
      languageCode: 'km',
      countryCode: 'KH',
      flagAsset: 'assets/flags/km.png',
    ),
    LocaleOption(
      displayName: '中文',
      languageCode: 'zh',
      countryCode: 'CN',
      flagAsset: 'assets/flags/zh.png',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.read<String>('lang');
    if (saved != null) {
      final parts = saved.split('_');
      if (parts.length == 2) {
        changeLanguage(parts[0], parts[1], persist: false);
      }
    }
  }

  void changeLanguage(String lang, String country, {bool persist = true}) {
    final locale = Locale(lang, country);
    currentLocale.value = locale;
    Get.updateLocale(locale);
    if (persist) {
      _storage.write('lang', '${lang}_$country');
    }
  }

  LocaleOption get currentLocaleOption {
    return supportedLocales.firstWhere(
      (l) => l.languageCode == currentLocale.value.languageCode,
      orElse: () => supportedLocales.first,
    );
  }

  bool get isKhmer => currentLocale.value.languageCode == 'km';
  bool get isChinese => currentLocale.value.languageCode == 'zh';
  bool get isEnglish => currentLocale.value.languageCode == 'en';
}
