import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/i18n/i18n.dart';

class GlobalService extends GetxService {
  final box = GetStorage();
  final _isDarkMode = Get.isDarkMode.obs;
  // final api = IndexProvider.to;

  Future<GlobalService> init() async {
    debugPrint('初始化 services');
    await initDarkMode();
    await initLocale();

    return this;
  }

  static GlobalService get to => Get.find();

  get isDarkMode => _isDarkMode.value;
  set isDarkMode(value) => _isDarkMode.value = value;
  switchDarkMode() {
    _isDarkMode.value = !_isDarkMode.value;
  }

  initDarkMode() async { 
    _isDarkMode.listen((value) async {
      debugPrint('isDarkMode $value'); 
      Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
      await box.writeBool(GetStorage.isDarkMode, value);
    });
      _isDarkMode.value =
        await box.readBool(GetStorage.isDarkMode) ?? Get.isDarkMode;
  }

  get local => _local;

  final _local = Get.deviceLocale.obs;

  switchLocal(I18nEnum locale) {
    _local.value = locale.locale;
  }

  initLocale() async {
    _local.listen((value) async {
      if (value != null) {
        Get.updateLocale(value);
        debugPrint('save local ${value.toString()}');
        await box.writeString(GetStorage.local, value.toString());
      }
    });

    String? localStr = await box.readString(GetStorage.local);

    for (I18nEnum value in I18nEnum.values) {
      if (value.value == localStr) {
        _local.value = value.locale;
        Get.updateLocale(value.locale);
      }
    }
  }
}
