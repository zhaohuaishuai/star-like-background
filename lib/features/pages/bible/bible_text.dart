import 'package:flutter/material.dart';
import 'package:m/features/pages/bible/bible_dict.dart';

class BibleText extends StatefulWidget {
  final VoidCallback onLongPress;
  final List<int> selectIndex;
  final int index;
  final Color textColor;
  final BibleData bibleData;
  const BibleText(
      {super.key,
      required this.onLongPress,
      required this.selectIndex,
      required this.index,
      required this.textColor,
      required this.bibleData});

  @override
  State<BibleText> createState() => _BibleTextState();
}

class _BibleTextState extends State<BibleText> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: widget.onLongPress,
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            '${widget.index + 1} ${widget.bibleData.data.trimLeft()}',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 24,
              height: 2.0,
              color: widget.textColor,
              decoration: widget.selectIndex.contains(widget.index)
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ));
  }
}
