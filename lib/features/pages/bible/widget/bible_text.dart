

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m/features/pages/bible/model/bible_model.dart';
import 'package:m/features/pages/bible/module/bible_content.dart';
import 'package:m/features/pages/bible/widget/bible_flash_border.dart';
import 'package:m/plugins/star_provider/index.dart';

class BibleText extends StatelessWidget {
  final BibleContent bibleContent;
  final VoidCallback? onLongPress;
  const BibleText({super.key,required this.bibleContent,this.onLongPress});

  @override
  Widget build(BuildContext context) {
    BibleModel bibleModel = context.watch<BibleModel>();
    bool selected = bibleModel.verseNumbers.contains(bibleContent.VerseSN);
    // 外部跳转进入时的渐显渐隐高亮：命中闪烁节集合时用虚线框包裹
    bool flashing = bibleModel.flashVerses.contains(bibleContent.VerseSN);

    Widget text = Align(
      alignment: Alignment.topLeft,
      child: Text(
        '${bibleContent.VerseSN} ${bibleContent.Lection.trimLeft()}', 
        style: TextStyle(decoration:  selected ? TextDecoration.underline:TextDecoration.none),
        ),
    );

    // 渐显渐隐动画只作用于虚线框图层，文字保持不透明
    if (flashing) {
      text = Stack(
        children: [
          text,
          Positioned.fill(
            child: ValueListenableBuilder<double>(
              valueListenable: bibleModel.flashOpacity,
              builder: (context, opacity, child) => Opacity(
                opacity: opacity,
                child: const CustomPaint(
                  painter: DashedBorderPainter(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      );
    }

   return GestureDetector(
    onLongPress: (){  
      HapticFeedback.vibrate();
      bibleModel.selectVerseNumber(bibleContent.VerseSN);    
    },
    child: text,
   );
  }
}