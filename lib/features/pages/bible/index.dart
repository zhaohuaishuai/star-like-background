import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/data/api/bible.dart';
import 'package:m/features/pages/bible/model/bible_model.dart';
import 'package:m/features/pages/bible/module/bible_panel_vo.dart';
import 'package:m/features/pages/bible/widget/bible_index.dart';
import 'package:m/plugins/star_provider/index.dart';

class BiblePage extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const BiblePage({super.key, this.arguments});
  @override
  State<StatefulWidget> createState() => BiblePageState();
}

class BiblePageState extends State<BiblePage>
    with SingleTickerProviderStateMixin {
  final BibleProvider api = BibleProvider();
  List<BiblePanelVo> biblePanelVoList = [];
  late final BibleModel bibleController;

  /// 渐显渐隐动画控制器：600ms 一个淡入淡出周期，循环播放
  late final AnimationController flashController;

  @override
  void initState() {
    super.initState();
    bibleController = BibleModel(arguments: Get.arguments);
    flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        // 动画帧驱动虚线框透明度，仅通知监听该值的组件
        bibleController.flashOpacity.value = flashController.value;
      });
    bibleController.flashController = flashController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
          listenable: bibleController,
          builder: (context, childr) {
            return StarProviderWidget(
              model: bibleController,
              child: const BibleIndex(),
            );
          }),
    );
  }

  @override
  void dispose() {
    flashController.dispose();
    bibleController.dispose();
    super.dispose();
  }
}
