import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';
import 'package:flatex/util/math_constants.dart';

class SqrtLayoutBox extends LayoutBox {
  final double lineThickness;
  final Color lineColor;
  final TextStyle symbolStyle;
  final bool isDisplayStyle;

  SqrtLayoutBox({
    required super.bounds,
    required super.children,
    super.offset,
    required this.lineThickness,
    required this.lineColor,
    required this.symbolStyle,
    this.isDisplayStyle = false,
  });

  @override
  void draw(Canvas canvas) {
    if (children.isEmpty) {
      super.draw(canvas);
      return;
    }
    
    final contentBox = children[0];
    
    // Draw the radical symbol with correct proportions
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Calculate positions with correct proportions
    final double contentHeight = contentBox.height;
    final double contentWidth = contentBox.width;
    
    // Radical symbol dimensions based on content
    final double radicalWidth = contentHeight * 0.4;
    final double hookDepth = contentHeight * 0.1;
    
    // Positioning coordinates for the radical
    final double startX = offset.dx;
    final double topY = offset.dy;
    final double baselineY = topY + contentHeight;
    
    // Path for the radical symbol following proper typography
    final path = Path();
    
    // Start at bottom left of hook
    path.moveTo(startX, baselineY - hookDepth);
    
    // Draw the hook (bottom part of the radical)
    path.lineTo(startX + radicalWidth * 0.4, baselineY);
    
    // Draw the upstroke of the radical
    path.lineTo(startX + radicalWidth, topY);
    
    // Draw the horizontal bar over the content
    path.lineTo(startX + radicalWidth + contentWidth, topY);
    
    // Draw the path
    canvas.drawPath(path, paint);
    
    // Draw children (content under the radical)
    super.draw(canvas);
  }
}
