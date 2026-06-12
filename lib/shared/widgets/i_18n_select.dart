import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/data/services/global.dart';
import 'package:m/i18n/i18n.dart';

class I18nSelect extends GetWidget {
  const I18nSelect({super.key});
  @override
  Widget build(BuildContext context) {
    Icon icon = const Icon(Icons.translate);
    for (I18nEnum value in I18nEnum.values) {
      if (value.value == GlobalService.to.local.toString()) {
        icon = value.icon;
      }
    }
    return PopupMenuButton(
      icon: icon,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: Row(
              children: [
                Text('中文'.tr),
                const Spacer(),
                const Icon(
                  Icons.translate,
                  size: 14,
                )
              ],
            ),
            onTap: () => GlobalService.to.switchLocal(I18nEnum.Chinese),
          ),
          PopupMenuItem(
            onTap: () => GlobalService.to.switchLocal(I18nEnum.En),
            child: Row(
              children: [
                Text('英文'.tr),
                const Spacer(),
                const Icon(
                  Icons.g_translate,
                  size: 14,
                )
              ],
            ),
          ),
        ];
      },
    );
  }
}
