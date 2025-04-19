import 'package:flatex/model/node.dart';

/// Subscript node for _{} construct
final class SubscriptNode extends LaTeXNode {
  /// Base of the subscript
  final LaTeXNode base;

  /// Subscript of the base
  final LaTeXNode subscript;

  const SubscriptNode({
    required this.base,
    required this.subscript,
    required super.startPosition,
    required super.endPosition,
  });

  @override
  T accept<T>(LaTeXNodeVisitor<T> visitor) => visitor.visitSubscriptNode(this);
}
