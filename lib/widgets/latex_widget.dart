import 'package:flatex/parser/parser.dart';
import 'package:flutter/material.dart';
import 'package:flatex/renderer/layout.dart';
import 'package:flatex/renderer/layout_builder.dart';
import 'package:flatex/model/node.dart';

class LatexWidget extends StatefulWidget {
  final String latexCode;
  final TextStyle textStyle;
  final TextStyle mathStyle;
  final double scale;

  const LatexWidget({
    super.key,
    required this.latexCode,
    this.textStyle = const TextStyle(fontSize: 16.0, color: Colors.black),
    this.mathStyle = const TextStyle(fontSize: 16.0, color: Colors.black),
    this.scale = 1.0,
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
        oldWidget.scale != widget.scale) {
      _parseAndLayout();
    }
  }

  void _parseAndLayout() {
    try {
      final parser = LatexParser(widget.latexCode);
      _rootNode = parser.parse();
      
      // Apply scale to font sizes
      final scaledTextStyle = widget.textStyle.copyWith(
        fontSize: (widget.textStyle.fontSize ?? 16.0) * widget.scale
      );
      final scaledMathStyle = widget.mathStyle.copyWith(
        fontSize: (widget.mathStyle.fontSize ?? 16.0) * widget.scale
      );
      
      final layoutBuilder = LatexLayoutBuilder(
        baseTextStyle: scaledTextStyle,
        mathStyle: scaledMathStyle,
      );
      _layoutBox = _rootNode.accept(layoutBuilder);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
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
