import 'package:flutter/material.dart';
import 'dart:math' as math;

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
    // Draw the fraction line with rounded caps for a more polished look
    final lineY = offset.dy + bounds.height / 2;
    final paint = Paint()
      ..color = linePaint.color
      ..strokeWidth = lineThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(offset.dx + 2.0, lineY),
      Offset(offset.dx + bounds.width - 2.0, lineY),
      paint,
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
    
    // Swift implementation uses taller radical sign
    final symbolHeight = math.max(contentHeight * 1.7, 18.0);
    final symbolWidth = symbolHeight * 0.7;
    final symbolYOffset = contentHeight * 0.03;
    
    // Similar to Swift implementation - use thicker stroke
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineThickness * 1.5
      ..strokeCap = StrokeCap.round;
    
    // More vertical radical path as seen in Swift implementation
    final path = Path();
    
    // Starting point slightly more to the left like Swift
    final startX = offset.dx;
    final startY = offset.dy + contentHeight * 0.75; // Position closer to the Swift implementation
    
    // Swift implementation uses a more vertical path
    path.moveTo(startX, startY);
    path.lineTo(startX + symbolWidth * 0.3, startY);
    path.lineTo(startX + symbolWidth * 0.5, offset.dy + contentHeight); 
    path.lineTo(startX + symbolWidth * 0.7, offset.dy - contentHeight * 0.1);
    
    // Draw the horizontal line extending from the radical
    final lineY = offset.dy + symbolYOffset;
    final lineEndX = offset.dx + bounds.width;
    
    path.lineTo(lineEndX, lineY);
    
    canvas.drawPath(path, paint);
    
    // Draw the children
    super.draw(canvas);
  }
}

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
          ..strokeCap = StrokeCap.round
      );
    }
    
    // Draw children (subscripts, superscripts)
    super.draw(canvas);
  }
}