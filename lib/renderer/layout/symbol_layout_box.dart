import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';

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
