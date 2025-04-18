
// Base abstract class for all LaTeX syntax nodes
abstract class LatexNode {
  // Position information for error reporting
  final int startPosition;
  final int endPosition;
  
  const LatexNode({
    required this.startPosition,
    required this.endPosition,
  });
  
  // Method to accept a visitor (Visitor pattern)
  T accept<T>(LatexNodeVisitor<T> visitor);
}

// Visitor pattern interface for traversing the syntax tree
abstract class LatexNodeVisitor<T> {
  T visitTextNode(TextNode node);
  T visitMathNode(MathNode node);
  T visitGroupNode(GroupNode node);
  T visitCommandNode(CommandNode node);
  T visitEnvironmentNode(EnvironmentNode node);
  T visitSymbolNode(SymbolNode node);
  T visitFractionNode(FractionNode node);
  T visitSuperscriptNode(SuperscriptNode node);
  T visitSubscriptNode(SubscriptNode node);
  T visitMatrixNode(MatrixNode node);
  T visitErrorNode(ErrorNode node);
}

// Plain text node
class TextNode extends LatexNode {
  final String text;
  const TextNode({
    required this.text,
    required super.startPosition,
    required super.endPosition,
  });
  @override
  T accept<T>(LatexNodeVisitor<T> visitor) => visitor.visitTextNode(this);
}

// Math mode node (inline or display)
class MathNode extends LatexNode {
  final List<LatexNode> children;
  final bool isDisplayMode; // true for $$...$$ or \[...\], false for $...$ or \(...\)
  const MathNode({
    required this.children,
    required this.isDisplayMode,
    required super.startPosition,
    required super.endPosition,
  });
  @override
  T accept<T>(LatexNodeVisitor<T> visitor) => visitor.visitMathNode(this);
}

// Group node for {...}
class GroupNode extends LatexNode {
  final List<LatexNode> children;
  const GroupNode({
    required this.children,
    required super.startPosition,
    required super.endPosition,
  });
  @override
  T accept<T>(LatexNodeVisitor<T> visitor) => visitor.visitGroupNode(this);
}

// Command node for \command[options]{arg1}{arg2}...
class CommandNode extends LatexNode {
  final String name;
  final List<String> options; // Optional [options]
  final List<LatexNode> arguments; // Required {arguments}
  const CommandNode({
    required this.name,
    required this.options,
    required this.arguments,
    required super.startPosition,
    required super.endPosition,
  });
  @override
  T accept<T>(LatexNodeVisitor<T> visitor) => visitor.visitCommandNode(this);
}

// Environment node for \begin{env}...\end{env}
class EnvironmentNode extends LatexNode {
  final String name;
  final List<String> options; // Optional [options]
  final List<LatexNode> content;
  const EnvironmentNode({
    required this.name,
    required this.options,
    required this.content,
    required super.startPosition,
    required super.endPosition,
  });
  @override
  T accept<T>(LatexNodeVisitor<T> visitor) => visitor.visitEnvironmentNode(this);
}

// Symbol node for special LaTeX symbols like \alpha, \sum, etc.
class SymbolNode extends LatexNode {
  final String name;
  const SymbolNode({
    required this.name,
    required super.startPosition,
    required super.endPosition,
  });
  @override
  T accept<T>(LatexNodeVisitor<T> visitor) => visitor.visitSymbolNode(this);
}

// Fraction node for \frac{}{} construct
class FractionNode extends LatexNode {
  final LatexNode numerator;
  final LatexNode denominator;
  const FractionNode({
    required this.numerator,
    required this.denominator,
    required super.startPosition,
    required super.endPosition,
  });
  @override
  T accept<T>(LatexNodeVisitor<T> visitor) => visitor.visitFractionNode(this);
}

// Superscript node for ^{} construct
class SuperscriptNode extends LatexNode {
  final LatexNode base;
  final LatexNode exponent;
  const SuperscriptNode({
    required this.base,
    required this.exponent,
    required super.startPosition,
    required super.endPosition,
  });
  @override
  T accept<T>(LatexNodeVisitor<T> visitor) => visitor.visitSuperscriptNode(this);
}

// Subscript node for _{} construct
class SubscriptNode extends LatexNode {
  final LatexNode base;
  final LatexNode subscript;
  const SubscriptNode({
    required this.base,
    required this.subscript,
    required super.startPosition,
    required super.endPosition,
  });
  @override
  T accept<T>(LatexNodeVisitor<T> visitor) => visitor.visitSubscriptNode(this);
}

// Matrix node for matrix environments
class MatrixNode extends LatexNode {
  final String type; // matrix, pmatrix, bmatrix, etc.
  final List<List<LatexNode>> cells;
  const MatrixNode({
    required this.type,
    required this.cells,
    required super.startPosition,
    required super.endPosition,
  });
  @override
  T accept<T>(LatexNodeVisitor<T> visitor) => visitor.visitMatrixNode(this);
}

// Error node for syntax errors
class ErrorNode extends LatexNode {
  final String message;
  final LatexNode? partialNode;
  const ErrorNode({
    required this.message,
    this.partialNode,
    required super.startPosition,
    required super.endPosition,
  });
  @override
  T accept<T>(LatexNodeVisitor<T> visitor) => visitor.visitErrorNode(this);
}
