import 'package:flatex/model/nodes/text_node.dart';
import 'package:flatex/model/nodes/math_node.dart';
import 'package:flatex/model/nodes/group_node.dart';
import 'package:flatex/model/nodes/command_node.dart';
import 'package:flatex/model/nodes/environment_node.dart';
import 'package:flatex/model/nodes/symbol_node.dart';
import 'package:flatex/model/nodes/fraction_node.dart';
import 'package:flatex/model/nodes/superscript_node.dart';
import 'package:flatex/model/nodes/subscript_node.dart';
import 'package:flatex/model/nodes/matrix_node.dart';
import 'package:flatex/model/nodes/error_node.dart';

/// Interface for nodes in the LaTeX syntax tree.
/// These nodes are created during the parsing process.
abstract class LaTeXNode {
  /// Start position of the node in the LaTeX string.
  final int startPosition;

  /// End position of the node in the LaTeX string.
  final int endPosition;

  const LaTeXNode({required this.startPosition, required this.endPosition});

  /// Method to accept a visitor. (Visitor pattern)
  /// This method will be used to traverse the syntax tree
  /// and perform different actions on each type of node.
  T accept<T>(LaTeXNodeVisitor<T> visitor);
}

/// Visitor pattern interface that allows us to traverse the syntax tree
abstract class LaTeXNodeVisitor<T> {
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
