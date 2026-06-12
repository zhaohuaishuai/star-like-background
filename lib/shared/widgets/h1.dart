import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/shared/widgets/spacing.dart';

// ignore: must_be_immutable
class H1 extends StatelessWidget {
  String title;
  H1({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacing(
          top: StarThemeData.spacing,
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
