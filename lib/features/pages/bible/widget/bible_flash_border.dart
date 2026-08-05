import 'package:flutter/material.dart';

/// 虚线选中框绘制器
///
/// 沿矩形四边绘制虚线边框，用于外部跳转进入经文页时的闪烁高亮提示。
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  const DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 4,
    this.gapWidth = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // 边框微缩进，避免贴边被裁切
    const double inset = 1;
    final double w = size.width - inset * 2;
    final double h = size.height - inset * 2;

    final Path path = Path();
    _addDashedLine(path, const Offset(inset, inset), Offset(inset + w, inset),
        dashWidth, gapWidth);
    _addDashedLine(path, Offset(inset + w, inset), Offset(inset + w, inset + h),
        dashWidth, gapWidth);
    _addDashedLine(path, Offset(inset + w, inset + h), Offset(inset, inset + h),
        dashWidth, gapWidth);
    _addDashedLine(path, Offset(inset, inset + h), const Offset(inset, inset),
        dashWidth, gapWidth);

    canvas.drawPath(path, paint);
  }

  /// 在 path 上按 虚线长/间距 追加一段虚线线段
  void _addDashedLine(
      Path path, Offset start, Offset end, double dashWidth, double gapWidth) {
    final double length = (end - start).distance;
    final Offset direction = (end - start) / length;
    double traveled = 0;
    while (traveled < length) {
      final double dashEnd = (traveled + dashWidth).clamp(0, length);
      path.moveTo(
          start.dx + direction.dx * traveled, start.dy + direction.dy * traveled);
      path.lineTo(
          start.dx + direction.dx * dashEnd, start.dy + direction.dy * dashEnd);
      traveled += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.gapWidth != gapWidth;
  }
}
