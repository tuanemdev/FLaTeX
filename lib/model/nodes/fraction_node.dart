import 'package:flatex/model/node.dart';

/// Fraction node for \frac{}{} construct
final class FractionNode extends LaTeXNode {
  /// Numerator of the fraction
  final LaTeXNode numerator;

  /// Denominator of the fraction
  final LaTeXNode denominator;

  const FractionNode({
    required this.numerator,
    required this.denominator,
    required super.startPosition,
    required super.endPosition,
  });

  @override
  T accept<T>(LaTeXNodeVisitor<T> visitor) => visitor.visitFractionNode(this);
}
