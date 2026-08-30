import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:get/get.dart';

/// 歌词 UI 样式定义，基于实例字段支持动态字号
class LyricUI extends UINetease {
  /// 歌词字号本地存储 key
  static const String lyricFontSizeKey = 'lyric_font_size';

  /// 默认当前行字号
  static const double cDefaultSize = 22;

  /// 默认其他行字号
  static const double cOtherMainSize = 18;

  /// 歌词字号调节范围
  static const double fontSizeMin = 14;
  static const double fontSizeMax = 40;

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
  TextStyle getPlayingMainTextStyle() => TextStyle(
        color: Get.isDarkMode ? Colors.white : Colors.black,
        fontSize: defaultSize,
      );

  @override
  TextStyle getOtherMainTextStyle() => TextStyle(
        color: Get.isDarkMode ? Colors.white70 : Colors.black87,
        fontSize: otherMainSize,
      );
}
