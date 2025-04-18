import 'package:flutter/material.dart';

class LayoutBox {
  Rect bounds;
  Offset offset;
  final List<LayoutBox> children;
  
  LayoutBox({
    required this.bounds,
    this.offset = Offset.zero,
    List<LayoutBox>? children,
  }) : children = children ?? [];
  
  double get width => bounds.width;
  double get height => bounds.height;
  
  void translate(Offset delta) {
    offset += delta;
    bounds = bounds.translate(delta.dx, delta.dy);
    
    for (final child in children) {
      child.translate(delta);
    }
  }
  
  void draw(Canvas canvas) {
    // Draw debug bounds
    // final paint = Paint()
    //   ..color = Colors.blue.withOpacity(0.2)
    //   ..style = PaintingStyle.stroke;
    // canvas.drawRect(bounds, paint);
    
    for (final child in children) {
      child.draw(canvas);
    }
  }
}

class TextLayoutBox extends LayoutBox {
  final String text;
  final TextStyle style;
  final TextPainter textPainter;
  
  TextLayoutBox({
    required this.text,
    required this.style,
    required super.bounds,
    super.offset,
  }) : textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: TextDirection.ltr,
        )..layout();
  
  @override
  void draw(Canvas canvas) {
    super.draw(canvas);
    textPainter.paint(canvas, offset);
  }
}

class SymbolLayoutBox extends LayoutBox {
  final String symbol;
  final TextStyle style;
  final TextPainter textPainter;
  
  SymbolLayoutBox({
    required this.symbol,
    required this.style,
    required super.bounds,
    super.offset,
  }) : textPainter = TextPainter(
          text: TextSpan(text: symbol, style: style),
          textDirection: TextDirection.ltr,
        )..layout();
  
  @override
  void draw(Canvas canvas) {
    super.draw(canvas);
    textPainter.paint(canvas, offset);
  }
}

class FractionLayoutBox extends LayoutBox {
  final double lineThickness;
  final Paint linePaint;
  
  FractionLayoutBox({
    required super.bounds,
    required List<LayoutBox> super.children,
    required this.lineThickness,
    super.offset,
    Color lineColor = const Color(0xFF000000),
  }) : linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = lineThickness
        ..style = PaintingStyle.fill;
  
  @override
  void draw(Canvas canvas) {
    // Draw the fraction line
    final lineY = offset.dy + bounds.height / 2;
    canvas.drawLine(
      Offset(offset.dx, lineY),
      Offset(offset.dx + bounds.width, lineY),
      linePaint,
    );
    
    super.draw(canvas);
  }
}

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
  }) : borderPaint = Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke;
  
  @override
  void draw(Canvas canvas) {
    // Draw different brackets based on matrix type
    switch (type) {
      case 'pmatrix':
        // Parentheses
        final paint = Paint()
          ..color = borderPaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;
        
        // Left parenthesis
        final leftPath = Path()
          ..moveTo(offset.dx + 5, offset.dy)
          ..quadraticBezierTo(
            offset.dx, offset.dy + bounds.height / 2,
            offset.dx + 5, offset.dy + bounds.height
          );
        
        // Right parenthesis
        final rightPath = Path()
          ..moveTo(offset.dx + bounds.width - 5, offset.dy)
          ..quadraticBezierTo(
            offset.dx + bounds.width, offset.dy + bounds.height / 2,
            offset.dx + bounds.width - 5, offset.dy + bounds.height
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
          Offset(offset.dx + bounds.width - padding - 5, offset.dy + bounds.height),
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

class SqrtLayoutBox extends LayoutBox {
  final double padding;
  final double symbolWidth;
  final double symbolHeight;

  SqrtLayoutBox({
    required super.bounds,
    required this.padding,
    List<LayoutBox> super.children = const [],
    this.symbolWidth = 10.0,
    this.symbolHeight = 5.0,
  });

  @override
  void draw(Canvas canvas) {
    // Draw the square root symbol with better proportions
    final path = Path();
    final startX = offset.dx;
    final startY = offset.dy + bounds.height * 0.75;
    final sqrtHeight = bounds.height;
    
    // Start at the bottom
    path.moveTo(startX, startY);
    // Draw the diagonal upward
    path.lineTo(startX + symbolWidth * 0.5, startY);
    // Small diagonal down
    path.lineTo(startX + symbolWidth * 0.8, startY - sqrtHeight * 0.1);
    // Diagonal up to top
    path.lineTo(startX + symbolWidth * 1.2, startY - sqrtHeight * 0.8);
    // Horizontal line covering the content
    path.lineTo(startX + bounds.width, startY - sqrtHeight * 0.8);

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, paint);

    // Draw the content of the square root
    super.draw(canvas);
  }
}

// Add a specialized layout box for sum symbols
class SumLayoutBox extends LayoutBox {
  final TextStyle style;
  final TextPainter sumPainter;
  
  SumLayoutBox({
    required String symbol,
    required this.style,
    required super.bounds,
    super.offset,
    super.children,
  }) : sumPainter = TextPainter(
          text: TextSpan(text: symbol, style: style),
          textDirection: TextDirection.ltr,
        )..layout();
  
  @override
  void draw(Canvas canvas) {
    // Draw the sum symbol centered
    sumPainter.paint(canvas, Offset(
      offset.dx + (bounds.width - sumPainter.width) / 2,
      offset.dy
    ));
    
    // Draw children (subscripts, superscripts)
    super.draw(canvas);
  }
}