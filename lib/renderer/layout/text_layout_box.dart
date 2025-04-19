import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout/layout_box.dart';
import 'package:flatex/util/font_loader.dart';

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
         text: TextSpan(
           text: text, 
           style: style.copyWith(
             fontFamily: style.fontFamily ?? MathFontLoader.defaultMathFont,
           ),
         ),
         textDirection: TextDirection.ltr,
       )..layout();

  @override
  void draw(Canvas canvas) {
    super.draw(canvas);
    textPainter.paint(canvas, offset);
  }
}
