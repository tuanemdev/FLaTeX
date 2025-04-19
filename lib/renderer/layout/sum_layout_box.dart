import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';

class SumLayoutBox extends LayoutBox {
  final TextStyle style;
  final TextPainter sumPainter;
  final bool hasLimits;

  SumLayoutBox({
    required String symbol,
    required this.style,
    required super.bounds,
    super.offset,
    super.children,
    this.hasLimits = false,
  }) : sumPainter = TextPainter(
         text: TextSpan(text: symbol, style: style),
         textDirection: TextDirection.ltr,
       )..layout();

  @override
  void draw(Canvas canvas) {
    // Position the sum symbol centered horizontally with refined vertical position
    final symbolX = offset.dx + (bounds.width - sumPainter.width) / 2;
    double symbolY = offset.dy;

    // Adjust the position based on limits
    if (hasLimits && children.length >= 2) {
      // With both limits
      final topScript = children[0];
      symbolY += topScript.height + 4.0;
    } else if (hasLimits && children.isNotEmpty) {
      // With just one limit
      symbolY += 8.0;
    }

    // Draw the sum symbol - use custom drawing for better quality
    if (style.fontFamily != null) {
      // Use the font if specified
      sumPainter.paint(canvas, Offset(symbolX, symbolY));
    } else {
      // Draw a custom sum symbol for better quality
      final height = bounds.height * 0.6;
      final width = height * 0.8;
      final x = symbolX + (sumPainter.width - width) / 2;
      final y = symbolY + (sumPainter.height - height) / 2;

      final sumPath = Path();

      // Top horizontal line
      sumPath.moveTo(x, y);
      sumPath.lineTo(x + width, y);

      // Diagonal line
      sumPath.moveTo(x + width * 0.9, y + height * 0.1);
      sumPath.lineTo(x + width * 0.1, y + height * 0.9);

      // Bottom horizontal line
      sumPath.moveTo(x, y + height);
      sumPath.lineTo(x + width, y + height);

      canvas.drawPath(
        sumPath,
        Paint()
          ..color = style.color ?? Colors.black
          ..strokeWidth = style.fontSize! / 10.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Draw children (subscripts, superscripts)
    super.draw(canvas);
  }
}
