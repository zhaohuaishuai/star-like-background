import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';

// ignore: must_be_immutable
class ShimmerWidget extends StatefulWidget {
  EdgeInsetsGeometry? padding;
  Widget? child;
  ShimmerWidget({
    super.key,
    this.padding,
    this.child,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          left: StarThemeData.spacing, right: StarThemeData.spacing),
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
              color: context.isDarkMode ? Colors.black : Colors.grey[200]),
          child: widget.child ??
              Text(
                '数据加载中...'.tr,
                style: TextStyle(color: StarThemeData.loadingTextColor),
              ),
        ),
      ),
    );
  }
}
