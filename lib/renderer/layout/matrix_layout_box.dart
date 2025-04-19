import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';

class MatrixLayoutBox extends LayoutBox {
  final String type;
  final Paint borderPaint;
  final double borderWidth;

  MatrixLayoutBox({
    required this.type,
    required super.bounds,
    required List<LayoutBox> super.children,
    super.offset,
    Color borderColor = const Color(0xFF000000),
    this.borderWidth = 1.0,
  }) : borderPaint =
           Paint()
             ..color = borderColor
             ..strokeWidth = borderWidth
             ..style = PaintingStyle.stroke;

  @override
  void draw(Canvas canvas) {
    // Draw different brackets based on matrix type
    switch (type) {
      case 'pmatrix':
        // Parentheses
        final paint =
            Paint()
              ..color = borderPaint.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = borderWidth;

        // Left parenthesis
        final leftPath =
            Path()
              ..moveTo(offset.dx + 5, offset.dy)
              ..quadraticBezierTo(
                offset.dx,
                offset.dy + bounds.height / 2,
                offset.dx + 5,
                offset.dy + bounds.height,
              );

        // Right parenthesis
        final rightPath =
            Path()
              ..moveTo(offset.dx + bounds.width - 5, offset.dy)
              ..quadraticBezierTo(
                offset.dx + bounds.width,
                offset.dy + bounds.height / 2,
                offset.dx + bounds.width - 5,
                offset.dy + bounds.height,
              );

        canvas.drawPath(leftPath, paint);
        canvas.drawPath(rightPath, paint);
        break;

      case 'bmatrix':
        // Square brackets
        final padding = 2.0;

        // Left bracket
        canvas.drawLine(
          Offset(offset.dx + padding, offset.dy),
          Offset(offset.dx + padding, offset.dy + bounds.height),
          borderPaint,
        );

        // Top-left corner
        canvas.drawLine(
          Offset(offset.dx + padding, offset.dy),
          Offset(offset.dx + padding + 5, offset.dy),
          borderPaint,
        );

        // Bottom-left corner
        canvas.drawLine(
          Offset(offset.dx + padding, offset.dy + bounds.height),
          Offset(offset.dx + padding + 5, offset.dy + bounds.height),
          borderPaint,
        );

        // Right bracket
        canvas.drawLine(
          Offset(offset.dx + bounds.width - padding, offset.dy),
          Offset(offset.dx + bounds.width - padding, offset.dy + bounds.height),
          borderPaint,
        );

        // Top-right corner
        canvas.drawLine(
          Offset(offset.dx + bounds.width - padding, offset.dy),
          Offset(offset.dx + bounds.width - padding - 5, offset.dy),
          borderPaint,
        );

        // Bottom-right corner
        canvas.drawLine(
          Offset(offset.dx + bounds.width - padding, offset.dy + bounds.height),
          Offset(
            offset.dx + bounds.width - padding - 5,
            offset.dy + bounds.height,
          ),
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
