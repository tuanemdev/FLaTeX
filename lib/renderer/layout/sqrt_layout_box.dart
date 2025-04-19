import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flatex/renderer/layout/layout_box.dart';

class SqrtLayoutBox extends LayoutBox {
  final double lineThickness;
  final Color lineColor;
  final String sqrtSymbol;
  final TextStyle symbolStyle;
  final TextPainter symbolPainter;

  SqrtLayoutBox({
    required super.bounds,
    List<LayoutBox> super.children = const [],
    super.offset,
    this.lineThickness = 1.5,
    this.lineColor = Colors.black,
    this.sqrtSymbol = '√',
    TextStyle? symbolStyle,
  }) : symbolStyle = (symbolStyle ?? TextStyle(fontSize: 20, color: lineColor)),
       symbolPainter = TextPainter(
         text: TextSpan(
           text: '√',
           style: (symbolStyle ?? TextStyle(fontSize: 20, color: lineColor)),
         ),
         textDirection: TextDirection.ltr,
       )..layout();

  @override
  void draw(Canvas canvas) {
    // Get content dimensions
    final contentHeight = children.isNotEmpty ? children.first.height : bounds.height * 0.6;
    final contentWidth = children.isNotEmpty ? children.first.width : bounds.width * 0.6;

    // More proportional radical sign - use both height and width for better proportions
    final symbolHeight = math.min(contentHeight * 1.3, bounds.height * 0.95);
    // Use contentWidth to help determine a good width for the radical symbol
    final symbolWidth = math.min(symbolHeight * 0.6, contentWidth * 0.15);
    
    // Slight vertical offset to align with content
    final symbolYOffset = contentHeight * 0.05;

    // Use thicker stroke for better clarity
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineThickness
      ..strokeCap = StrokeCap.round;

    // Create a path for a vertically oriented radical sign
    final path = Path();

    // Starting point at lower left of radical
    final startX = offset.dx + 2.0;
    final startY = offset.dy + contentHeight * 0.7; // Position for the slant part

    // First horizontal segment at bottom
    path.moveTo(startX, startY);
    path.lineTo(startX + symbolWidth * 0.4, startY);
    
    // Vertical line up to the content
    path.lineTo(startX + symbolWidth * 0.4, offset.dy + contentHeight * 0.9);
    
    // Diagonal ascender - shorter and not so steep
    path.lineTo(startX + symbolWidth * 0.7, offset.dy - contentHeight * 0.05);

    // Draw the horizontal line extending from the radical - aligned with top of content
    final lineY = offset.dy + symbolYOffset;
    final lineEndX = offset.dx + bounds.width;

    path.lineTo(lineEndX, lineY);

    canvas.drawPath(path, paint);

    // Draw the children
    super.draw(canvas);
  }
}
