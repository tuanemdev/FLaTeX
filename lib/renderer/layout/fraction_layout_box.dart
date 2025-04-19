import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';
import 'package:flatex/util/math_constants.dart';

class FractionLayoutBox extends LayoutBox {
  final double lineThickness;
  final Paint linePaint;
  final bool isDisplayStyle;

  FractionLayoutBox({
    required super.bounds,
    required List<LayoutBox> super.children,
    required this.lineThickness,
    super.offset,
    Color lineColor = const Color(0xFF000000),
    this.isDisplayStyle = false,
  }) : linePaint =
           Paint()
             ..color = lineColor
             ..strokeWidth = lineThickness
             ..style = PaintingStyle.fill;

  @override
  void draw(Canvas canvas) {
    if (children.length < 2) {
      super.draw(canvas);
      return;
    }

    final numeratorBox = children[0];
    final denominatorBox = children[1];
    
    // Calculate the line position at the mathematical axis height
    final fontSize = lineThickness / MathConstants.defaultRuleThickness(1.0);
    
    // The line should be positioned at the middle of the fraction height
    final lineY = offset.dy + numeratorBox.height + 
                  (isDisplayStyle ? 
                      MathConstants.fractionNumeratorDisplayStyleGapMin(fontSize) : 
                      MathConstants.fractionNumeratorGapMin(fontSize));
    
    final paint = Paint()
      ..color = linePaint.color
      ..strokeWidth = lineThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw the line with proper width
    canvas.drawLine(
      Offset(offset.dx + 2.0, lineY),
      Offset(offset.dx + bounds.width - 2.0, lineY),
      paint,
    );

    super.draw(canvas);
  }
}
