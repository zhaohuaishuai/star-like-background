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

  /// 渐显渐隐动画控制器：3 秒一次播完（渐显→保持→渐隐），不循环
  late final AnimationController flashController;

  /// 透明度分段动画：前 15% 渐显、中间 70% 保持、后 15% 渐隐
  static final Animatable<double> _flashOpacityAnimation =
      TweenSequence<double>([
    TweenSequenceItem(
      tween:
          Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
      weight: 15,
    ),
    TweenSequenceItem(
      tween: ConstantTween<double>(1.0),
      weight: 70,
    ),
    TweenSequenceItem(
      tween:
          Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 15,
    ),
  ]);

  @override
  void initState() {
    super.initState();
    bibleController = BibleModel(arguments: Get.arguments);
    flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )
      ..addListener(() {
        // 动画帧驱动虚线框透明度，仅通知监听该值的组件
        bibleController.flashOpacity.value =
            _flashOpacityAnimation.evaluate(flashController);
      })
      ..addStatusListener((status) {
        // 动画播完（已渐隐至 0）后清理高亮状态
        if (status == AnimationStatus.completed) {
          bibleController.clearFlash();
        }
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
