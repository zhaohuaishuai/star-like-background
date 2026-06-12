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

class BiblePageState extends State<BiblePage> {
  final BibleProvider api = BibleProvider();
  List<BiblePanelVo> biblePanelVoList = [];
  late final BibleModel bibleController;

  @override
  void initState() {
    super.initState();
    bibleController = BibleModel(arguments: Get.arguments);
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
    bibleController.dispose();
    super.dispose();
  }
}
