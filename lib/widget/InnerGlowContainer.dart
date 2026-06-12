import 'package:flutter/material.dart';

class InnerGlowContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double blurRadius;
  final double spreadRadius;
  final double borderRadius;
  final Offset offset;

  const InnerGlowContainer({
    Key? key,
    required this.child,
    this.color = Colors.white,
    this.blurRadius = 20.0,
    this.spreadRadius = 5.0,
    this.borderRadius = 0.0,
    this.offset = const Offset(0, 0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: offset,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}