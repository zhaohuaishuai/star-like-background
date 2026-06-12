import 'package:flutter/material.dart';

/// 下划线动画颜色
class AnimatedUnderLineText extends StatefulWidget {
  final String? data;
  final TextStyle? textStyle;
  final Duration? duration;
  final bool? selected;
  final Color? strokeColor;
  final double? strokeWidth;
  final void Function()? onLongPress; // 长按事件
  const AnimatedUnderLineText(String this.data,
      {this.textStyle = const TextStyle(color: Colors.black, fontSize: 24),
      this.duration,
      this.selected,
      this.strokeColor,
      this.strokeWidth,
      this.onLongPress,
      super.key});
  @override
  State<AnimatedUnderLineText> createState() => _AnimatedUnderLineTextState();
}

class _AnimatedUnderLineTextState extends State<AnimatedUnderLineText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(seconds: 1),
    );

    if (widget.selected == true) {
      _controller.forward();
    } else if (widget.selected == false) {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedUnderLineText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected == true) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr)
        ..text = TextSpan(
          text: widget.data,
          style: widget.textStyle,
        )
        ..layout(maxWidth: constraints.maxWidth);
      return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return GestureDetector(
              onLongPress: () {
                widget.onLongPress?.call();
                debugPrint('Long Pressed');
              },
              onTap: () {
                debugPrint('Tapped');
              },
              child: CustomPaint(
                size: Size(double.infinity, painter.height),
                painter: UnderLineTextPainter(
                  data: widget.data,
                  value: _controller.value,
                  textStyle: widget.textStyle ??
                      const TextStyle(fontSize: 12, color: Colors.black),
                  strokeColor: widget.strokeColor,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
            );
          });
    });
  }
}

class UnderLineTextPainter extends CustomPainter {
  final String? data; // 文本内容
  final double? strokeWidth;
  final TextStyle? textStyle;
  final double value; // 动画值
  final Color? strokeColor; // 下划线颜色
  const UnderLineTextPainter(
      {this.data,
      this.textStyle,
      required this.value,
      this.strokeWidth = 1,
      this.strokeColor = Colors.black});
  @override
  void paint(Canvas canvas, Size size) {
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: data,
        style: textStyle?.copyWith(
                decoration: TextDecoration.none, decorationStyle: null) ??
            const TextStyle(color: Colors.black, fontSize: 24),
      );

    textPainter.layout(maxWidth: size.width);
    textPainter.paint(canvas, Offset.zero); // 绘制文本

    /// 6.获取段落的行信息
    TextDecoration decoration =
        textStyle?.decoration ?? TextDecoration.underline;
    if (decoration == TextDecoration.none) {
      return;
    }

    final lineMetrics = textPainter.computeLineMetrics();
    final totalWidth = lineMetrics.map((e) => e.width).reduce((a, b) => a + b);
    double currentWidth = 0;
    double procressWidth = value * totalWidth;

    for (int i = 0; i < lineMetrics.length; i++) {
      LineMetrics element = lineMetrics[i];
      double bottom = element.baseline;
      if (decoration == TextDecoration.overline) {
        bottom = element.baseline - element.ascent;
      }
      if (decoration == TextDecoration.lineThrough) {
        bottom = element.baseline - element.descent;
      }

      double width = element.width;
      double left = 0;
      if (currentWidth + width <= procressWidth) {
        left = element.left + width;
      }

      if (procressWidth >= currentWidth &&
          procressWidth < currentWidth + width) {
        left = element.left + (procressWidth - currentWidth);
      }

      canvas.drawLine(
          Offset(element.left, bottom),
          Offset(left, bottom),
          Paint()
            ..color = strokeColor!
            ..strokeWidth = strokeWidth!);

      currentWidth += width;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}