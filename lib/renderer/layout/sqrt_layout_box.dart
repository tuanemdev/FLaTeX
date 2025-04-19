import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';

class SqrtLayoutBox extends LayoutBox {
  final double lineThickness;
  final Color lineColor;
  final TextStyle symbolStyle;

  SqrtLayoutBox({
    required super.bounds,
    required super.children,
    super.offset,
    required this.lineThickness,
    required this.lineColor,
    required this.symbolStyle,
  });

  @override
  void draw(Canvas canvas) {
    // Draw the radical symbol
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineThickness
      ..style = PaintingStyle.stroke;

    // Calculate positions for the square root symbol parts
    final double height = bounds.height;
    final double contentWidth = children.isNotEmpty ? children[0].width : 0;
    final double symbolWidth = height * 0.5; // Width proportional to height

    // Starting point at the bottom-left of the symbol
    final startX = offset.dx + symbolWidth * 0.1;
    final baseY = offset.dy + height - lineThickness;
    
    // Path for the radical symbol
    final path = Path();
    path.moveTo(startX, baseY - height * 0.4); // Start at middle left
    path.lineTo(startX + symbolWidth * 0.3, baseY); // Down to bottom
    path.lineTo(startX + symbolWidth * 0.6, offset.dy + height * 0.3); // Up to top-right of symbol
    path.lineTo(startX + symbolWidth, offset.dy + height * 0.5); // Small hook at top
    
    // Horizontal line covering the content
    path.moveTo(startX + symbolWidth * 0.6, offset.dy + lineThickness); // Top-right of symbol
    path.lineTo(offset.dx + symbolWidth + contentWidth, offset.dy + lineThickness); // Horizontal line
    
    // Draw the path
    canvas.drawPath(path, paint);
    
    // Draw children (content under the radical)
    super.draw(canvas);
  }
}
