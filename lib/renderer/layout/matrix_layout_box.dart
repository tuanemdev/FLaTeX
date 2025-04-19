import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';
import 'package:flatex/util/math_constants.dart';

class MatrixLayoutBox extends LayoutBox {
  final String type;
  final Paint borderPaint;
  final double borderWidth;
  final double fontSize;

  MatrixLayoutBox({
    required this.type,
    required super.bounds,
    required List<LayoutBox> super.children,
    super.offset,
    Color borderColor = const Color(0xFF000000),
    this.borderWidth = 1.0,
    this.fontSize = 16.0,
  }) : borderPaint =
           Paint()
             ..color = borderColor
             ..strokeWidth = borderWidth
             ..style = PaintingStyle.stroke;

  @override
  void draw(Canvas canvas) {
    // Draw different brackets based on matrix type
    final bracketWidth = fontSize * 0.1; // Thinner brackets
    final bracketPadding = fontSize * 0.1;
    
    switch (type) {
      case 'pmatrix':
        // Parentheses with proper curvature
        final paint = Paint()
          ..color = borderPaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

        // Left parenthesis - less exaggerated curve
        final leftPath = Path();
        leftPath.moveTo(offset.dx + bracketPadding, offset.dy);
        leftPath.quadraticBezierTo(
          offset.dx, // Control point X
          offset.dy + bounds.height / 2, // Control point Y
          offset.dx + bracketPadding, // End point X
          offset.dy + bounds.height // End point Y
        );

        // Right parenthesis - less exaggerated curve
        final rightPath = Path();
        rightPath.moveTo(offset.dx + bounds.width - bracketPadding, offset.dy);
        rightPath.quadraticBezierTo(
          offset.dx + bounds.width, // Control point X
          offset.dy + bounds.height / 2, // Control point Y
          offset.dx + bounds.width - bracketPadding, // End point X
          offset.dy + bounds.height // End point Y
        );

        canvas.drawPath(leftPath, paint);
        canvas.drawPath(rightPath, paint);
        break;

      case 'bmatrix':
        // Square brackets with standard proportions
        final thickness = borderWidth;
        final cornerSize = fontSize * 0.2;
        
        // Left bracket parts
        // Vertical line
        canvas.drawLine(
          Offset(offset.dx + bracketPadding, offset.dy + cornerSize),
          Offset(offset.dx + bracketPadding, offset.dy + bounds.height - cornerSize),
          borderPaint,
        );
        
        // Top horizontal part
        canvas.drawLine(
          Offset(offset.dx + bracketPadding, offset.dy + thickness/2),
          Offset(offset.dx + bracketPadding + cornerSize, offset.dy + thickness/2),
          borderPaint,
        );
        
        // Bottom horizontal part
        canvas.drawLine(
          Offset(offset.dx + bracketPadding, offset.dy + bounds.height - thickness/2),
          Offset(offset.dx + bracketPadding + cornerSize, offset.dy + bounds.height - thickness/2),
          borderPaint,
        );

        // Right bracket parts
        // Vertical line
        canvas.drawLine(
          Offset(offset.dx + bounds.width - bracketPadding, offset.dy + cornerSize),
          Offset(offset.dx + bounds.width - bracketPadding, offset.dy + bounds.height - cornerSize),
          borderPaint,
        );
        
        // Top horizontal part
        canvas.drawLine(
          Offset(offset.dx + bounds.width - bracketPadding, offset.dy + thickness/2),
          Offset(offset.dx + bounds.width - bracketPadding - cornerSize, offset.dy + thickness/2),
          borderPaint,
        );
        
        // Bottom horizontal part
        canvas.drawLine(
          Offset(offset.dx + bounds.width - bracketPadding, offset.dy + bounds.height - thickness/2),
          Offset(offset.dx + bounds.width - bracketPadding - cornerSize, offset.dy + bounds.height - thickness/2),
          borderPaint,
        );
        break;

      default:
        // No brackets for plain matrix
        break;
    }

    super.draw(canvas);
  }
}
