import 'package:flatex/model/node.dart';

/// Math mode node (inline or display)
final class MathNode extends LaTeXNode {
  /// List of child nodes within the math mode
  final List<LaTeXNode> children;

  /// Whether the math mode is in display mode
  /// true for $$...$$ or \[...\], false for $...$ or \(...\)
  final bool isDisplayMode;

  const MathNode({
    required this.children,
    required this.isDisplayMode,
    required super.startPosition,
    required super.endPosition,
  });

  @override
  T accept<T>(LaTeXNodeVisitor<T> visitor) => visitor.visitMathNode(this);
}
