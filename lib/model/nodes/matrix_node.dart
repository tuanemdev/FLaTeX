import 'package:flatex/model/node.dart';

/// Matrix node for matrix environments
final class MatrixNode extends LaTeXNode {
  /// Type of matrix (e.g., "pmatrix", "bmatrix", etc.)
  final String type;

  /// Cells of the matrix, each cell can contain a list of LaTeX nodes
  final List<List<LaTeXNode>> cells;

  const MatrixNode({
    required this.type,
    required this.cells,
    required super.startPosition,
    required super.endPosition,
  });

  @override
  T accept<T>(LaTeXNodeVisitor<T> visitor) => visitor.visitMatrixNode(this);
}
