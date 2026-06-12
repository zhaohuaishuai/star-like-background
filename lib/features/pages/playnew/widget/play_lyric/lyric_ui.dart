import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:get/get.dart';

class LyricUI extends UINetease {
  static const double cDefaultSize = 22;
  static const double cOtherMainSize = 18;
  static TextStyle get playingMainTextStyle => TextStyle(
        color: Get.isDarkMode ? Colors.white : Colors.black,
        fontSize: cDefaultSize,
      );
  static TextStyle get otherMainTextStyle => TextStyle(
        color: Get.isDarkMode ? Colors.white70 : Colors.black87,
        fontSize: cOtherMainSize,
      );
  LyricUI(
      {super.highlight = false,
      super.defaultSize = cDefaultSize,
      super.otherMainSize = cOtherMainSize});
  LyricUI.clone(UINetease uiNetease)
      : this(
          defaultSize: uiNetease.defaultSize,
          otherMainSize: uiNetease.otherMainSize,
        );

  @override
  Color getLyricHightlightColor() =>
      Get.isDarkMode ? Colors.amber : Colors.white;

  @override
  TextStyle getPlayingMainTextStyle() {
    return playingMainTextStyle;
  }

  @override
  TextStyle getOtherMainTextStyle() {
    return otherMainTextStyle;
  }
}
