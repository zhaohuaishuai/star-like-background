import 'package:flutter/material.dart';

/// 图标文字组合组件
/// 用于显示上方图标下方文字的垂直布局
class IconTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final double iconSize;
  final double textSize;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final double spacing;

  const IconTextWidget({
    Key? key,
    required this.icon,
    required this.text,
    this.iconSize = 36,
    this.textSize = 14,
    this.iconColor,
    this.textColor,
    this.onTap,
    this.spacing = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
          SizedBox(height: spacing),
          Text(
            text,
            style: TextStyle(
              fontSize: textSize,
              color: textColor,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }
}
