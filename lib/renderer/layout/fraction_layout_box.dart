import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';

class FractionLayoutBox extends LayoutBox {
  final double lineThickness;
  final Paint linePaint;

  FractionLayoutBox({
    required super.bounds,
    required List<LayoutBox> super.children,
    required this.lineThickness,
    super.offset,
    Color lineColor = const Color(0xFF000000),
  }) : linePaint =
           Paint()
             ..color = lineColor
             ..strokeWidth = lineThickness
             ..style = PaintingStyle.fill;

  @override
  void draw(Canvas canvas) {
    // Draw the fraction line with rounded caps for a more polished look
    final lineY = offset.dy + bounds.height / 2;
    final paint =
        Paint()
          ..color = linePaint.color
          ..strokeWidth = lineThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(offset.dx + 2.0, lineY),
      Offset(offset.dx + bounds.width - 2.0, lineY),
      paint,
    );

    super.draw(canvas);
  }
}
