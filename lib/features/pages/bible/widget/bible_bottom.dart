import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/features/pages/bible/model/bible_model.dart';
import 'package:m/plugins/star_provider/index.dart';

class BibleBottom extends StatelessWidget {
  final Color? bgColor;
  final bool isShow;
  const BibleBottom({super.key, this.bgColor, required this.isShow});
  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).padding.bottom;
    final bibleModel = context.watch<BibleModel>();
    bottom = bibleModel.isSelect ? bottom + kToolbarHeight + 8 : -100.0;
    bottom = isShow ? bottom : -kToolbarHeight;
    final textColor = context.isDarkMode ? Colors.white : Colors.black;
    return AnimatedPositioned(
      left: 0,
      right: 0,
      bottom: bottom,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Container(
          // height: 46,rrr
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 12, color: textColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          bibleModel.copy();
                        },
                        icon: const Icon(Icons.copy)),
                    const Text(
                      '复制经文',
                    )
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          bibleModel.addBookmark();
                        },
                        icon: const Icon(Icons.bookmark_add_outlined)),
                    const Text('加入书签')
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          bibleModel.clearSelect();
                        },
                        icon: const Icon(Icons.clear_all_outlined)),
                    const Text('清空选择')
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
