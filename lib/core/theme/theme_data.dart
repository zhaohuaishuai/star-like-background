import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/constants/constants.dart';

class StarThemeData {
  static double miniPlayerBottom = 100;
  static double miniPlayerHeight = 56;
  static double bottomSheetHeight = 360;
  static double bottomAppBarHeight = 56;
  static Color bgColor = const Color(0XFFF4F7FA);
  static double spacing = 12;
  static Color primaryColor = Colors.red;
  static Color? loadingTextColor = Colors.grey[600]; //Colors.redAccent;
  static Gradient playGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryColor.withOpacity(0.6),
      primaryColor.withOpacity(0.95),
    ],
  );

  static Gradient darkPlayGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      primaryColor.withOpacity(0.4),
      primaryColor.withOpacity(0.8),
    ],
  );

  static Gradient dalogBgGradient = LinearGradient(
    colors: [
      primaryColor.withOpacity(1),
      bgColor.withOpacity(0.8),
      bgColor.withOpacity(0.4),
      bgColor.withOpacity(0.2),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: const [0.0, 0.14, 0.2, 1],
  );

  static Gradient darkDalogBgGradient = LinearGradient(
    colors: [
      primaryColor.withOpacity(1),
      bgColor.withOpacity(0.8),
      bgColor.withOpacity(0.4),
      bgColor.withOpacity(0.2),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: const [0.0, 0.14, 0.2, 1],
  );

  static ThemeData light = ThemeData.light().copyWith(
    // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    primaryColor: primaryColor, //const Color(0XFF0F1020)
    appBarTheme: ThemeData.light().appBarTheme.copyWith(
        backgroundColor: bgColor, surfaceTintColor: Colors.transparent),
    bottomNavigationBarTheme: ThemeData.light()
        .bottomNavigationBarTheme
        .copyWith(
            backgroundColor: bgColor,
            selectedItemColor: const Color(0XFF0F1020)),
    scaffoldBackgroundColor: bgColor,
    inputDecorationTheme: const InputDecorationTheme(
        fillColor: Color(0xffE8E9ED),
        filled: true,
        labelStyle: TextStyle(color: Colors.blueGrey),
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(28.0)))),

    // primaryColor: Colors.blue,
    sliderTheme: ThemeData.light().sliderTheme.copyWith(
          thumbColor: Colors.black,
          activeTrackColor: Colors.black.withOpacity(0.8),
          inactiveTickMarkColor: Colors.black.withOpacity(0.3),
          activeTickMarkColor: Colors.black.withOpacity(0.8),
          trackHeight: 2.0,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
        ),
    popupMenuTheme:
        ThemeData.light().popupMenuTheme.copyWith(color: Colors.white),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: StarThemeData.primaryColor,
        backgroundColor: bgColor,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        // backgroundColor: bgColor,
        foregroundColor: StarThemeData.primaryColor,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: StarThemeData.primaryColor,
      indicatorColor: StarThemeData.primaryColor,
    ),
  );

  static ThemeData dark = ThemeData.dark().copyWith(
    inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(28.0)))),
    appBarTheme: ThemeData.dark().appBarTheme.copyWith(
          surfaceTintColor: Colors.transparent,
        ),
    bottomNavigationBarTheme: ThemeData.dark()
        .bottomNavigationBarTheme
        .copyWith(selectedItemColor: const Color(0XFF92949B)),
    sliderTheme: ThemeData.light().sliderTheme.copyWith(
          thumbColor: Colors.white,
          activeTrackColor: Colors.white.withOpacity(0.8),
          inactiveTrackColor: Colors.white.withOpacity(0.3),
          activeTickMarkColor: Colors.white.withOpacity(0.8),
          trackHeight: 2.0,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: StarThemeData.primaryColor,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: StarThemeData.primaryColor,
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: StarThemeData.primaryColor,
      indicatorColor: StarThemeData.primaryColor,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor.withOpacity(0.5),
      ),
    ),
  );

  static double get bottomPadding =>
      MediaQuery.of(Get.context!).padding.bottom +
      kBottomNavigationBarHeight +
      StarThemeData.spacing;

  static String get coverUrl =>
      Get.theme.brightness == Brightness.dark ? playDarkCoverUrl : playCoverUrl;
}
