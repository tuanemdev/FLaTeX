import 'package:flatex/model/node.dart';

/// Error node for syntax errors
final class ErrorNode extends LaTeXNode {
  /// Error message
  final String message;

  /// Optional partial node that caused the error
  final LaTeXNode? partialNode;

  const ErrorNode({
    required this.message,
    this.partialNode,
    required super.startPosition,
    required super.endPosition,
  });

  @override
  T accept<T>(LaTeXNodeVisitor<T> visitor) => visitor.visitErrorNode(this);
}
