import 'package:flutter/material.dart';

class Spacing extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double? x;
  final double? y;

  const Spacing(
      {super.key,
      this.top,
      this.bottom,
      this.left,
      this.right,
      this.x,
      this.y});

  @override
  Widget build(BuildContext context) {
    final double x = this.x ?? 0;
    final double y = this.y ?? 0;

    if (x != 0 || y != 0) {
      return Padding(
        padding: EdgeInsets.only(
          top: y,
          bottom: y,
          left: x,
          right: x,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: top ?? 0,
        bottom: bottom ?? 0,
        left: left ?? 0,
        right: right ?? 0,
      ),
    );
  }
}
