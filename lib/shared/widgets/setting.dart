import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/app/routes.dart';

class SettingWidget extends GetWidget {
  const SettingWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => Get.toNamed(AppRoutes.settings),
    );
  }
}
