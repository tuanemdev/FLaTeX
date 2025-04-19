import 'package:flatex/model/node.dart';

/// Group node for {...}
final class GroupNode extends LaTeXNode {
  /// List of child nodes within the group
  final List<LaTeXNode> children;

  const GroupNode({
    required this.children,
    required super.startPosition,
    required super.endPosition,
  });

  @override
  T accept<T>(LaTeXNodeVisitor<T> visitor) => visitor.visitGroupNode(this);
}
