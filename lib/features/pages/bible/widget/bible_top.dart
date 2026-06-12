import 'package:flutter/material.dart';
import 'package:m/features/pages/bible/model/bible_model.dart';
import 'package:m/plugins/star_provider/index.dart';

class BibleTop extends StatelessWidget {
  final Color? bgColor;
  final bool isShow;
  const BibleTop({super.key, this.bgColor, required this.isShow});
  @override
  Widget build(BuildContext context) {
    final bibleModel = context.watch<BibleModel>();
    double top = MediaQuery.of(context).padding.top;
    double bottom = MediaQuery.of(context).padding.bottom;
    bottom = isShow ? bottom : -kToolbarHeight;
    return AnimatedPositioned(
      // top: 0,
      left: 0,
      right: 0,
      bottom: bottom,
      duration: const Duration(milliseconds: 300),
      child: Container(
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1), // 阴影方向：向下偏移1像素
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () {
                  bibleModel.scrollToIndex(0);
                  bibleModel.preChapter();
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                ),
                label: const Text(
                  '上一章',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              TextButton.icon(
                iconAlignment: IconAlignment.end,
                onPressed: () {
                  bibleModel.scrollToIndex(0);
                  bibleModel.nextChapter();
                },
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                label: const Text(
                  '下一章',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          )),
    );
  }
}
