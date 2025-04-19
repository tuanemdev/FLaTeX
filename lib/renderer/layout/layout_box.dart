import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Base class for all layout boxes
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
    if (kDebugMode) {
      final paint =
          Paint()
            ..color = Colors.blue.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke;
      canvas.drawRect(bounds, paint);
    }

    for (final child in children) {
      child.draw(canvas);
    }
  }
}
