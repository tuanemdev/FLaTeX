import 'package:flatex/model/node.dart';

/// Plain text node
final class TextNode extends LaTeXNode {
  /// Text content of the node
  final String text;

  const TextNode({
    required this.text,
    required super.startPosition,
    required super.endPosition,
  });

  @override
  T accept<T>(LaTeXNodeVisitor<T> visitor) => visitor.visitTextNode(this);
}
