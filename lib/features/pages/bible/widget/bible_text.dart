

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
    // 外部跳转进入时的闪烁高亮：命中闪烁节集合且当前处于可见相位
    bool flashing = bibleModel.flashVerses.contains(bibleContent.VerseSN) &&
        bibleModel.flashVisible;

    Widget text = Align(
      alignment: Alignment.topLeft,
      child: Text(
        '${bibleContent.VerseSN} ${bibleContent.Lection.trimLeft()}', 
        style: TextStyle(decoration:  selected ? TextDecoration.underline:TextDecoration.none),
        ),
    );

    // 闪烁相位可见时用虚线选中框包裹
    if (flashing) {
      text = CustomPaint(
        painter: const DashedBorderPainter(color: Colors.red),
        child: text,
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