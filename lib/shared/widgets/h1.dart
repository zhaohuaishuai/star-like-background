import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/shared/widgets/spacing.dart';

// ignore: must_be_immutable
class H1 extends StatelessWidget {
  String title;

  /// 标题下方与内容之间的间距，默认与标题上方一致
  final double? bottomSpacing;

  H1({super.key, required this.title, this.bottomSpacing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacing(
          top: bottomSpacing ?? StarThemeData.spacing,
        ),
        Padding(
          padding: EdgeInsets.only(left: StarThemeData.spacing),
          child: Text(
            title.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Spacing(
          top: StarThemeData.spacing,
        ),
      ],
    );
  }
}
