import 'package:flutter/material.dart';

class Sliverpersistentheaderbuilder extends SliverPersistentHeaderDelegate {
  final Widget Function(
      BuildContext context, double shrinkOffset, bool overlapsContent) builder;
  final double max;
  final double min;

  Sliverpersistentheaderbuilder(
      {required this.builder, this.max = 120, this.min = 80})
      : assert(max >= min);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  double get maxExtent => max;

  @override
  double get minExtent => min;

  @override
  bool shouldRebuild(Sliverpersistentheaderbuilder oldDelegate) {
    return oldDelegate.builder != builder ||
        oldDelegate.max != max ||
        oldDelegate.min != min;
  }
}
