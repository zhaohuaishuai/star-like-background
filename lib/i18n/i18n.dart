// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/i18n/translations/en.dart';
import 'package:m/i18n/translations/zh.dart';

enum I18nEnum {
  Chinese('zh_CN', Locale('ch', 'CN'), Icon(Icons.translate)),
  En('en_US', Locale('en', 'US'), Icon(Icons.g_translate_rounded));

  final String value;
  final Locale locale;
  final Icon icon;
  const I18nEnum(this.value, this.locale, this.icon);
}

class I18n extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en,
        'zh_CN': zh,
      };
}
