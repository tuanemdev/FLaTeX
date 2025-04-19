import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';

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
