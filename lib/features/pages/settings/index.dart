import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/app/routes.dart';
import 'package:m/core/utils/battery_optimization.dart';
import 'package:m/features/pages/playnew/widget/lyric_font_size.dart';
import 'package:m/features/pages/settings/controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          if (Platform.isAndroid) ...[
            const ListTile(
              title: Text('电池策略优化'),
              subtitle: Text('解决音乐背景播放时程序被系统关闭的问题, 进入设置页后选择【省电策略】——>【无限制】'),
              onTap: BatteryOptimizationUtils.requestIgnoreBatteryOptimizations,
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ],
          // 歌词字体大小
          Obx(() => ListTile(
                title: const Text('歌词字体大小'),
                subtitle:
                    Text('当前: ${controller.lyricFontSize.value.round()}px'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => showLyricFontSizeDialog(
                  context,
                  fontSize: controller.lyricFontSize.value,
                  onChanged: (value) => controller.setLyricFontSize(value),
                ),
              )),
          // 音频缓存
          ListTile(
            title: const Text('文件缓存'),
            subtitle: const Text('查看和清理缓存文件'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Get.toNamed(AppRoutes.fileStore),
          ),
        ],
      ),
    );
  }
}
