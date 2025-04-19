import 'package:flatex/model/node.dart';

/// Environment node for \begin{env}...\end{env}
final class EnvironmentNode extends LaTeXNode {
  /// Environment name, e.g., "align", "equation", etc.
  final String name;

  /// Optional [options]
  final List<String> options;

  /// Content of the environment, which can be a list of LaTeX nodes.
  final List<LaTeXNode> content;

  const EnvironmentNode({
    required this.name,
    required this.options,
    required this.content,
    required super.startPosition,
    required super.endPosition,
  });

  @override
  T accept<T>(LaTeXNodeVisitor<T> visitor) =>
      visitor.visitEnvironmentNode(this);
}
