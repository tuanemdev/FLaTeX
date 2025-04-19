enum TokenType {
  text,
  command,
  beginGroup,
  endGroup,
  beginMath,
  endMath,
  beginDisplayMath,
  endDisplayMath,
  superscript,
  subscript,
  beginEnvironment,
  endEnvironment,
  beginOptions,
  endOptions,
  separator,
  whitespace,
  mathOperator,
  eof,
  error,
}

class Token {
  final TokenType type;
  final String value;
  final int position;

  const Token({
    required this.type,
    required this.value,
    required this.position,
  });

  @override
  String toString() => 'Token($type, "$value", $position)';
}
