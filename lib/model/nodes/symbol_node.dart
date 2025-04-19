import 'package:flatex/model/node.dart';

/// Symbol node for special LaTeX symbols like \alpha, \sum, etc.
final class SymbolNode extends LaTeXNode {
  /// Name of the symbol
  /// This is the LaTeX command name, e.g., \alpha would be "alpha"
  final String name;

  const SymbolNode({
    required this.name,
    required super.startPosition,
    required super.endPosition,
  });

  @override
  T accept<T>(LaTeXNodeVisitor<T> visitor) => visitor.visitSymbolNode(this);
}
