import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class CancelButton extends StatelessWidget {
  VoidCallback? onPressed;
  CancelButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
              Get.context!.isDarkMode ? Colors.white : Colors.black)),
      child:   Text('取消'.tr),
      onPressed: () => onPressed != null ? onPressed!() : Get.back(),
    );
  }
}
