import 'package:flutter/material.dart';
import 'package:m/features/pages/bible/bible_scroll_view.dart';
import 'package:m/features/pages/bible/model/bible_model.dart';
import 'package:m/features/pages/bible/module/bible_content.dart';
import 'package:m/features/pages/bible/widget/bible_font_size.dart';
import 'package:m/features/pages/bible/widget/bible_panel.dart';
import 'package:m/features/pages/bible/widget/bible_text.dart';
import 'package:m/plugins/star_provider/index.dart';
import 'package:m/shared/widgets/loading.dart';

import 'dart:core';

class BibleBody extends StatefulWidget {
  final Color bgColor;
  final Color textColor;
  final void Function(bool)? onDrawerChanged;

  const BibleBody(
      {super.key,
      required this.bgColor,
      required this.textColor,
      this.onDrawerChanged});

  @override
  State<BibleBody> createState() => _BibleBodyState();
}

class _BibleBodyState extends State<BibleBody> {
  @override
  Widget build(BuildContext context) {
    final bibleModel = context.watch<BibleModel>();
    final BibleScrollViewController controller = bibleModel.bibleController;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.5),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        title: Text(
          '${bibleModel.volumnSNFullName ?? '创世纪'} ${bibleModel.chapterSN}',
          style: const TextStyle(fontSize: 12, color: Colors.red),
        ),
        backgroundColor: widget.bgColor,
        actions: [
          const DrawerButton(),
          BibleFontSize(
            fontSize: bibleModel.fontSize,
            onFontSizeChanged: (value) {
              bibleModel.fontSize = value;
            },
          ),
          IconButton(
            onPressed: () {
              bibleModel.bookmark(context);
            },
            icon: const Icon(Icons.bookmark_outline, size: 24),
          ),
          IconButton(
            onPressed: () {
              bibleModel.play();
            },
            icon: StreamBuilder<bool>(
                stream: bibleModel.playingStream,
                builder: (context, snapshot) {
                  return Icon(
                    snapshot.data == true ? Icons.pause : Icons.play_arrow,
                    size: 24,
                  );
                }),
          ),
        ],
      ),
      drawer: const BiblePanel(),
      drawerEdgeDragWidth: 50,
      backgroundColor: widget.bgColor,
      onDrawerChanged: (isOpened) {
        widget.onDrawerChanged?.call(isOpened);
        if (!isOpened) {
          int? index = bibleModel.verseNumbers.firstOrNull;
          if (index != null) {
            bibleModel.scrollToIndex(index - 1);
          }
        } else {
          bibleModel.scrollToIndex(0);
        }
      },
      body: Padding(
        padding:
            const EdgeInsets.only(left: 18, right: 18, bottom: kToolbarHeight),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 100),
          style: TextStyle(
              fontSize: bibleModel.fontSize,
              color: widget.textColor,
              height: 2.4),
          textAlign: TextAlign.left,
          child: FutureBuilder(
            future: bibleModel.bibleContents,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data!;

                return BiblePageView(
                  bibleContent: data,
                  controller: controller,
                  bgColor: widget.bgColor,
                );
              }
              return const Center(
                child: LoadingWidget(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class BiblePageView extends StatefulWidget {
  final Color bgColor;
  final List<BibleContent> bibleContent;
  final BibleScrollViewController controller;
  const BiblePageView(
      {super.key,
      required this.bibleContent,
      required this.controller,
      required this.bgColor});

  @override
  State<BiblePageView> createState() => _BiblePageViewState();
}

class _BiblePageViewState extends State<BiblePageView> {
  late BibleModel bibleModel;
  late int chapterSN;
  late int chapterNumber;

  Offset _start = Offset.zero;
  double _distance = 0;
  bool isScroll = true;
  @override
  Widget build(BuildContext context) {
    bibleModel = context.watch<BibleModel>();
    chapterSN = bibleModel.chapterSN;
    chapterNumber = widget.bibleContent.length;
    final data = widget.bibleContent;
    final itemCount = data.length;
    Widget itemBuilder(BuildContext context, int index) {
      return BibleText(
        bibleContent: data[index],
      );
    }

    if (!bibleModel.inited) {
      return const Center(
        child: LoadingWidget(),
      );
    }

    return BibleScrollView(
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        controller: widget.controller);
  }
}
