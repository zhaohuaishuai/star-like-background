import 'package:flutter/material.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/features/pages/playnew/widget/play_lyric/lyric_ui.dart';

/// 弹出歌词字号调节对话框
/// 滑块主题色与项目主题色保持一致
void showLyricFontSizeDialog(
  BuildContext context, {
  required double fontSize,
  required ValueChanged<double> onChanged,
}) {
  // 弹窗内维护的当前字号，保证滑块拖动过程实时显示
  double current = fontSize;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('歌词字体大小'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('当前: ${current.round()}px',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Slider(
                  value: current,
                  min: LyricUI.fontSizeMin,
                  max: LyricUI.fontSizeMax,
                  divisions:
                      (LyricUI.fontSizeMax - LyricUI.fontSizeMin).toInt(),
                  label: '${current.round()}px',
                  activeColor: StarThemeData.primaryColor,
                  onChanged: (value) {
                    setState(() => current = value);
                    onChanged(value);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            child: const Text('确定'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/// 歌词页字号调节按钮
class LyricFontSizeButton extends StatelessWidget {
  /// 当前歌词字号
  final double fontSize;

  /// 字号变化回调
  final ValueChanged<double> onChanged;

  /// 图标颜色
  final Color? iconColor;

  const LyricFontSizeButton(
      {super.key,
      required this.fontSize,
      required this.onChanged,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.format_size, size: 30, color: iconColor),
      tooltip: '调整歌词字体大小',
      onPressed: () => showLyricFontSizeDialog(context,
          fontSize: fontSize, onChanged: onChanged),
    );
  }
}
