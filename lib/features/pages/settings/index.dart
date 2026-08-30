import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/app/routes.dart';
import 'package:m/core/utils/battery_optimization.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/features/pages/playnew/widget/play_lyric/lyric_ui.dart';
import 'package:m/features/pages/settings/controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  /// 弹出歌词字体大小调节对话框
  void _showLyricFontSizeDialog(BuildContext context) {
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
                  Text('当前: ${controller.lyricFontSize.value.round()}px',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Slider(
                    value: controller.lyricFontSize.value,
                    min: LyricUI.fontSizeMin,
                    max: LyricUI.fontSizeMax,
                    divisions:
                        (LyricUI.fontSizeMax - LyricUI.fontSizeMin).toInt(),
                    label: '${controller.lyricFontSize.value.round()}px',
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (value) {
                      controller.setLyricFontSize(value);
                      setState(() {});
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
                subtitle: Text('当前: ${controller.lyricFontSize.value.round()}px'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showLyricFontSizeDialog(context),
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
