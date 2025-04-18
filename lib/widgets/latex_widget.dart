import 'dart:io';

import 'package:flatex/parser/parser.dart';
import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout.dart';
import 'package:flatex/renderer/layout_builder.dart';
import 'package:flatex/model/node.dart';
import 'package:flatex/util/font_loader.dart';

class LatexWidget extends StatefulWidget {
  final String latexCode;
  final TextStyle textStyle;
  final TextStyle mathStyle;
  final double scale;
  final bool useDefaultFont;
  final String? fontFamily;

  const LatexWidget({
    super.key,
    required this.latexCode,
    this.textStyle = const TextStyle(fontSize: 16.0, color: Colors.black),
    this.mathStyle = const TextStyle(fontSize: 16.0, color: Colors.black),
    this.scale = 1.0,
    this.useDefaultFont = false,
    this.fontFamily,
  });

  @override
  State<LatexWidget> createState() => _LatexWidgetState();
}

class _LatexWidgetState extends State<LatexWidget> {
  late LatexNode _rootNode;
  late LayoutBox _layoutBox;
  String? _error;

  @override
  void initState() {
    super.initState();
    _parseAndLayout();
  }

  @override
  void didUpdateWidget(LatexWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latexCode != widget.latexCode ||
        oldWidget.textStyle != widget.textStyle ||
        oldWidget.mathStyle != widget.mathStyle ||
        oldWidget.scale != widget.scale ||
        oldWidget.useDefaultFont != widget.useDefaultFont ||
        oldWidget.fontFamily != widget.fontFamily) {
      _parseAndLayout();
    }
  }

  void _parseAndLayout() {
    try {
      final parser = LatexParser(widget.latexCode);
      _rootNode = parser.parse();
      
      // Select the font family from the provided options or use default
      final String? mathFontFamily = widget.useDefaultFont ? null : _selectMathFont();
      
      // Apply enhanced scale to font sizes
      final scaledTextStyle = widget.textStyle.copyWith(
        fontSize: (widget.textStyle.fontSize ?? 16.0) * widget.scale,
        fontWeight: FontWeight.normal,  // Ensure proper weight for text
        height: 1.2,  // Improve line height
      );
      
      final scaledMathStyle = widget.mathStyle.copyWith(
        fontSize: (widget.mathStyle.fontSize ?? 16.0) * widget.scale,
        fontFamily: mathFontFamily,
        letterSpacing: -0.2,  // Tighter spacing like Swift implementation
        height: 1.0,  // Match Swift's tight line height
        fontWeight: FontWeight.normal,
      );
      
      final layoutBuilder = LatexLayoutBuilder(
        baseTextStyle: scaledTextStyle,
        mathStyle: scaledMathStyle,
        fontSize: (widget.mathStyle.fontSize ?? 16.0) * widget.scale,
        fractionGap: 6.0 * widget.scale,  // Wider gap for fractions like Swift
        fractionLineThickness: 1.5 * widget.scale,  // Thicker lines like Swift
        scriptScaleFactor: 0.60,  // Swift uses smaller subscripts/superscripts
        baselineOffset: 2.0 * widget.scale, // Improved baseline positioning
        superscriptShift: 5.0 * widget.scale, // Refined superscript positioning
        subscriptShift: 3.0 * widget.scale, // Refined subscript positioning
        matrixCellPadding: 6.0 * widget.scale, // More padding like Swift
      );
      
      _layoutBox = _rootNode.accept(layoutBuilder);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
  }

  // Updated to use LatinModern as the default font
  String? _selectMathFont() {
    if (widget.fontFamily != null && MathFontLoader.mathFonts.contains(widget.fontFamily)) {
      return widget.fontFamily;
    }
    
    // Default to LatinModern for better math support
    return MathFontLoader.defaultMathFont;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Text('LaTeX Error: $_error', style: const TextStyle(color: Colors.red));
    }
    return CustomPaint(
      size: Size(_layoutBox.width, _layoutBox.height),
      painter: _LatexPainter(_layoutBox),
    );
  }
}

class _LatexPainter extends CustomPainter {
  final LayoutBox layoutBox;

  _LatexPainter(this.layoutBox);

  @override
  void paint(Canvas canvas, Size size) {
    layoutBox.draw(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
