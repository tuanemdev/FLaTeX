import "package:flatex/parser/token.dart";

/// A simple lexer for LaTeX that tokenizes the input string into meaningful tokens.
final class LaTeXLexer {
  /// The input string to be tokenized.
  final String input;

  /// The current position in the input string.
  int position = 0;

  LaTeXLexer(this.input);

  /// Determines if the lexer has reached the end of the input string.
  bool get isEOF => position >= input.length;

  /// Get the character at the current position.
  String peek([int offset = 0]) {
    final index = position + offset;
    if (index >= input.length) return '';
    return input[index];
  }

  void advance([int count = 1]) {
    position += count;
  }

  Token nextToken() {
    if (isEOF) {
      return Token(type: TokenType.eof, value: '', position: position);
    }

    final char = peek();

    // Handle whitespace separately to make it a distinct token
    if (isWhitespace(char)) {
      return scanWhitespace();
    }

    switch (char) {
      case r'\':
        if (peek(1) == '[') {
          advance(2);
          return Token(
            type: TokenType.beginDisplayMath,
            value: r'\[',
            position: position - 2,
          );
        } else if (peek(1) == ']') {
          advance(2);
          return Token(
            type: TokenType.endDisplayMath,
            value: r'\]',
            position: position - 2,
          );
        } else if (peek(1) == '(') {
          advance(2);
          return Token(
            type: TokenType.beginMath,
            value: r'\(',
            position: position - 2,
          );
        } else if (peek(1) == ')') {
          advance(2);
          return Token(
            type: TokenType.endMath,
            value: r'\)',
            position: position - 2,
          );
        } else {
          return scanCommand();
        }
      case '{':
        advance();
        return Token(
          type: TokenType.beginGroup,
          value: '{',
          position: position - 1,
        );
      case '}':
        advance();
        return Token(
          type: TokenType.endGroup,
          value: '}',
          position: position - 1,
        );
      case '[':
        advance();
        return Token(
          type: TokenType.beginOptions,
          value: '[',
          position: position - 1,
        );
      case ']':
        advance();
        return Token(
          type: TokenType.endOptions,
          value: ']',
          position: position - 1,
        );
      case r'$':
        if (peek(1) == r'$') {
          advance(2);
          return Token(
            type: TokenType.beginDisplayMath,
            value: r'$$',
            position: position - 2,
          );
        } else {
          advance();
          return Token(
            type: TokenType.beginMath,
            value: r'$',
            position: position - 1,
          );
        }
      case '^':
        advance();
        return Token(
          type: TokenType.superscript,
          value: '^',
          position: position - 1,
        );
      case '_':
        advance();
        return Token(
          type: TokenType.subscript,
          value: '_',
          position: position - 1,
        );
      case ',':
        advance();
        return Token(
          type: TokenType.separator,
          value: ',',
          position: position - 1,
        );
      default:
        return scanText();
    }
  }

  Token scanCommand() {
    final startPos = position;
    advance(); // Skip the backslash

    if (isEOF) {
      return Token(type: TokenType.error, value: r'\', position: startPos);
    }

    // Handle special cases like \begin and \end - using more efficient string comparison
    if (position + 4 < input.length &&
        input.substring(position, position + 5) == 'begin') {
      advance(5);
      return Token(
        type: TokenType.beginEnvironment,
        value: '\\begin',
        position: startPos,
      );
    } else if (position + 2 < input.length &&
        input.substring(position, position + 3) == 'end') {
      advance(3);
      return Token(
        type: TokenType.endEnvironment,
        value: '\\end',
        position: startPos,
      );
    }

    final buffer = StringBuffer();

    // Handle special single-character commands like \$, \&, etc.
    if (!isEOF && isSpecialCommandChar(peek())) {
      buffer.write(peek());
      advance();
      return Token(
        type: TokenType.command,
        value: '\\${buffer.toString()}',
        position: startPos,
      );
    }

    // Regular command
    while (!isEOF && isLaTeXCommandChar(peek())) {
      buffer.write(peek());
      advance();
    }

    return Token(
      type: TokenType.command,
      value: '\\${buffer.toString()}',
      position: startPos,
    );
  }

  Token scanText() {
    final startPos = position;
    final buffer = StringBuffer();

    while (!isEOF && !isSpecialChar(peek()) && !isWhitespace(peek())) {
      buffer.write(peek());
      advance();
    }

    return Token(
      type: TokenType.text,
      value: buffer.toString(),
      position: startPos,
    );
  }

  // New method to handle whitespace tokens
  Token scanWhitespace() {
    final startPos = position;
    final buffer = StringBuffer();

    while (!isEOF && isWhitespace(peek())) {
      buffer.write(peek());
      advance();
    }

    return Token(
      type: TokenType.whitespace,
      value: buffer.toString(),
      position: startPos,
    );
  }

  bool isLaTeXCommandChar(String char) {
    return RegExp(r'[a-zA-Z]').hasMatch(char);
  }

  bool isSpecialCommandChar(String char) {
    // LaTeX special command characters that can follow a backslash
    return r'$&%#_{}"\'.contains(char);
  }

  bool isSpecialChar(String char) {
    return r'{},\\$^_[]'.contains(char) || isWhitespace(char);
  }

  // New helper method to check for whitespace
  bool isWhitespace(String char) {
    return char == ' ' || char == '\t' || char == '\n' || char == '\r';
  }
}
