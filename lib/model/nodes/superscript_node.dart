import 'package:flatex/model/node.dart';

/// Superscript node for ^{} construct
final class SuperscriptNode extends LaTeXNode {
  /// Base of the superscript
  final LaTeXNode base;

  /// Superscript of the base
  final LaTeXNode exponent;

  const SuperscriptNode({
    required this.base,
    required this.exponent,
    required super.startPosition,
    required super.endPosition,
  });

  @override
  T accept<T>(LaTeXNodeVisitor<T> visitor) =>
      visitor.visitSuperscriptNode(this);
}
