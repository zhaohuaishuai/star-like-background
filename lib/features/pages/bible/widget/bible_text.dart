

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m/features/pages/bible/model/bible_model.dart';
import 'package:m/features/pages/bible/module/bible_content.dart';
import 'package:m/plugins/star_provider/index.dart';

class BibleText extends StatelessWidget {
  final BibleContent bibleContent;
  final VoidCallback? onLongPress;
  const BibleText({super.key,required this.bibleContent,this.onLongPress});

  @override
  Widget build(BuildContext context) {
    BibleModel bibleModel = context.watch<BibleModel>();
    bool selected = bibleModel.verseNumbers.contains(bibleContent.VerseSN);
   return GestureDetector(
    onLongPress: (){  
      HapticFeedback.vibrate();
      bibleModel.selectVerseNumber(bibleContent.VerseSN);    
    },
    child: Align(
      alignment: Alignment.topLeft,
      child: Text(
        '${bibleContent.VerseSN} ${bibleContent.Lection.trimLeft()}', 
        style: TextStyle(decoration:  selected ? TextDecoration.underline:TextDecoration.none),
        ),
      )
   );
  }
}