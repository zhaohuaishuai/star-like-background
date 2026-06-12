import 'package:flutter/material.dart';

class BibleActionsWidget extends StatefulWidget {
  final LayerLink link;
  const BibleActionsWidget({super.key, required this.link});

  @override
  State<BibleActionsWidget> createState() => _BibleActionsWidgetState();
}

class _BibleActionsWidgetState extends State<BibleActionsWidget> {
  final TextStyle _textStyle = const TextStyle(color: Colors.white, fontSize: 16);
  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      link: widget.link,
      showWhenUnlinked: false,
      offset: const Offset(0, -40),
      child: UnconstrainedBox(
        alignment: Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              TextButton(
                  onPressed: () {
                    debugPrint('复制');
                  },
                  child: Text(
                    '复制',
                    style: _textStyle,
                  )),
              Container(width: 1, height: 22, color: Colors.white60),
              TextButton(
                  onPressed: () {},
                  child: Text(
                    '添加书签',
                    style: _textStyle,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
