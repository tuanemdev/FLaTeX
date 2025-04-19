import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';
import 'package:flatex/util/font_loader.dart';

class SumLayoutBox extends LayoutBox {
  final TextStyle style;
  final TextPainter sumPainter;
  final bool hasLimits;
  final bool isLimitStyle; // New property to control limit positioning style

  SumLayoutBox({
    required String symbol,
    required this.style,
    required super.bounds,
    super.offset,
    super.children,
    this.hasLimits = false,
    this.isLimitStyle = true, // By default, display limits below and above
  }) : sumPainter = TextPainter(
         text: TextSpan(
           text: symbol, 
           style: style.copyWith(
             fontFamily: style.fontFamily ?? MathFontLoader.defaultMathFont,
           ),
         ),
         textDirection: TextDirection.ltr,
       )..layout();

  @override
  void draw(Canvas canvas) {
    // Position the sum symbol centered horizontally with refined vertical position
    final symbolX = offset.dx + (bounds.width - sumPainter.width) / 2;
    double symbolY = offset.dy;

    // Only adjust the vertical position if we're using limit style (display mode)
    if (isLimitStyle && hasLimits) {
      if (children.length >= 2) {
        // With both limits
        final topScript = children[0];
        symbolY += topScript.height + 4.0;
      } else if (children.isNotEmpty) {
        // With just one limit
        symbolY += 8.0;
      }
    }

    // Always use the font since we're now ensuring Latin Modern is available
    sumPainter.paint(canvas, Offset(symbolX, symbolY));

    // Draw children (subscripts, superscripts)
    super.draw(canvas);
  }
}
