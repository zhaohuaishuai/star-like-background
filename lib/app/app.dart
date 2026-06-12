import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:m/app/routes.dart';
import 'package:m/core/constants/constants.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/i18n/i18n.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 强制竖屏
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await GetStorage.init();
  GetStorage box = GetStorage();
  bool notFirstStart = await box.readBool(GetStorage.notFirstStart) ?? false;

  if (notFirstStart || kIsWeb) {
    await Utils.firstStartServices();
  }

  if (!kIsWeb && Platform.isIOS) {
    Utils.testNetWork();
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDnsUrl;
      options.diagnosticLevel = SentryLevel.debug;
    },
    // Init your App.
    appRunner: () => runApp(const MyApp()),
  );

  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName.tr,
      darkTheme: StarThemeData.dark,
      themeMode: ThemeMode.system,
      theme: StarThemeData.light,
      translations: I18n(),
      initialRoute: AppRoutes.index,
      getPages: AppRoutes.pages,
    );
  }
}
