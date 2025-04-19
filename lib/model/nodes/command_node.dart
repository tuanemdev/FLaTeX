import 'package:flatex/model/node.dart';

/// Command node for \command[options]{arg1}{arg2}...
final class CommandNode extends LaTeXNode {
  /// Command name, e.g., "frac", "sqrt", etc.
  final String name;

  /// Optional [options]
  final List<String> options;

  /// Required {arguments}
  final List<LaTeXNode> arguments;

  const CommandNode({
    required this.name,
    required this.options,
    required this.arguments,
    required super.startPosition,
    required super.endPosition,
  });

  @override
  T accept<T>(LaTeXNodeVisitor<T> visitor) => visitor.visitCommandNode(this);
}
