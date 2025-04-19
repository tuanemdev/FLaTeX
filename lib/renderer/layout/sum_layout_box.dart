import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';
import 'package:flatex/util/font_loader.dart';
import 'package:flatex/util/math_constants.dart';

class SumLayoutBox extends LayoutBox {
  final TextStyle style;
  final TextPainter sumPainter;
  final bool hasLimits;
  final bool isDisplayStyle; 

  SumLayoutBox({
    required String symbol,
    required this.style,
    required super.bounds,
    super.offset,
    super.children,
    this.hasLimits = false,
    this.isDisplayStyle = true,
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
    // First establish the vertical layout of all components
    final fontSize = style.fontSize ?? 16.0;
    
    // Position the sum symbol centered horizontally
    final symbolX = offset.dx + (bounds.width - sumPainter.width) / 2;
    double symbolY = offset.dy;

    // For display style with limits, we need to position them differently
    if (isDisplayStyle && hasLimits) {
      if (children.length > 0) {
        // Find superscript (if any) and add its height plus gap
        var upperLimit = children.length >= 1 ? children[0] : null;
        if (upperLimit != null) {
          symbolY = offset.dy + upperLimit.height + 
            MathConstants.upperLimitGapMin(fontSize);
        }
      }
    }

    // Draw the sum symbol at the calculated position
    sumPainter.paint(canvas, Offset(symbolX, symbolY));

    // Draw children (subscripts, superscripts)
    super.draw(canvas);
  }
}
