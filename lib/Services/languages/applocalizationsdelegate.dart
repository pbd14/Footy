import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Services/languages/en.dart';
import 'package:flutter_complete_guide/Services/languages/languages.dart';
import 'package:flutter_complete_guide/Services/languages/ru.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Languages> {

  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<Languages> load(Locale locale) => _load(locale);

  static Future<Languages> _load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'ru':
        return LanguageRu();
      default:
        return LanguageEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
  
}