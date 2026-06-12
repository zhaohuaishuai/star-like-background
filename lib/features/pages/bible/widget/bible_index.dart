import 'package:flutter/material.dart';

import 'package:m/features/pages/bible/widget/bible_body.dart';
import 'package:m/features/pages/bible/widget/bible_bottom.dart';

import 'package:m/features/pages/bible/widget/bible_top.dart';

extension on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDarkMode => (theme.brightness == Brightness.dark);
}

class BibleIndex extends StatefulWidget {
  const BibleIndex({super.key});
  @override
  State<BibleIndex> createState() => _BibleIndexState();
}

class _BibleIndexState extends State<BibleIndex> {
  @override
  void initState() {
    super.initState();
  }

  bool topIsShow = false;
  bool _isOpen = false;
  @override
  Widget build(BuildContext context) {
    Color textColor = context.isDarkMode ? Colors.white : Colors.black;
    Color bgColor = context.isDarkMode ? Colors.black : const Color(0xFFF5F5DC);
    // ignore: no_leading_underscores_for_local_identifiers

    return GestureDetector(
      child: Stack(
        children: [
          BibleBody(
            bgColor: bgColor,
            textColor: textColor,
            onDrawerChanged: (isOpened) {
              _isOpen = isOpened;
              setState(() {});
            },
          ),
          BibleBottom(
            bgColor: bgColor,
            isShow: !_isOpen,
          ),
          BibleTop(
            bgColor: bgColor,
            isShow: !_isOpen,
          ),
        ],
      ),
    );
  }
}
