import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:m/data/services/global.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => IconButton(
          icon: Icon(
            GlobalService.to.isDarkMode ? Icons.dark_mode : Icons.sunny,
            weight: 100,
          ),
          onPressed: () {
            GlobalService.to.switchDarkMode();
          },
        ));
  }
}
// ignore: unused_import
