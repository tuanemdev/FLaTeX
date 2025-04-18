import "package:flatex/parser/token.dart";

class LatexLexer {
  final String input;
  int position = 0;
  
  LatexLexer(this.input);
  
  bool get isEOF => position >= input.length;
  
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
    
    switch (char) {
      case '\\':
        if (peek(1) == '[') {
          advance(2);
          return Token(type: TokenType.beginDisplayMath, value: '\\[', position: position - 2);
        } else if (peek(1) == ']') {
          advance(2);
          return Token(type: TokenType.endDisplayMath, value: '\\]', position: position - 2);
        } else if (peek(1) == '(') {
          advance(2);
          return Token(type: TokenType.beginMath, value: '\\(', position: position - 2);
        } else if (peek(1) == ')') {
          advance(2);
          return Token(type: TokenType.endMath, value: '\\)', position: position - 2);
        } else {
          return scanCommand();
        }
      case '{':
        advance();
        return Token(type: TokenType.beginGroup, value: '{', position: position - 1);
      case '}':
        advance();
        return Token(type: TokenType.endGroup, value: '}', position: position - 1);
      case '[':
        advance();
        return Token(type: TokenType.beginOptions, value: '[', position: position - 1);
      case ']':
        advance();
        return Token(type: TokenType.endOptions, value: ']', position: position - 1);
      case r'$':
        if (peek(1) == r'$') {
          advance(2);
          return Token(type: TokenType.beginDisplayMath, value: r'$$', position: position - 2);
        } else {
          advance();
          return Token(type: TokenType.beginMath, value: r'$', position: position - 1);
        }
      case '^':
        advance();
        return Token(type: TokenType.superscript, value: '^', position: position - 1);
      case '_':
        advance();
        return Token(type: TokenType.subscript, value: '_', position: position - 1);
      case ',':
        advance();
        return Token(type: TokenType.separator, value: ',', position: position - 1);
      default:
        return scanText();
    }
  }
  
  Token scanCommand() {
    final startPos = position;
    advance(); // Skip the backslash
    
    if (isEOF) {
      return Token(type: TokenType.error, value: '\\', position: startPos);
    }
    
    // Handle special cases like \begin and \end - using more efficient string comparison
    if (position + 4 < input.length && 
        input.substring(position, position + 5) == 'begin') {
      advance(5);
      return Token(type: TokenType.beginEnvironment, value: '\\begin', position: startPos);
    } else if (position + 2 < input.length && 
               input.substring(position, position + 3) == 'end') {
      advance(3);
      return Token(type: TokenType.endEnvironment, value: '\\end', position: startPos);
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
    while (!isEOF && isLatexCommandChar(peek())) {
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
    
    while (!isEOF && !isSpecialChar(peek())) {
      buffer.write(peek());
      advance();
    }
    
    return Token(
      type: TokenType.text,
      value: buffer.toString(),
      position: startPos,
    );
  }
  
  bool isLatexCommandChar(String char) {
    return RegExp(r'[a-zA-Z]').hasMatch(char);
  }
  
  bool isSpecialCommandChar(String char) {
    // LaTeX special command characters that can follow a backslash
    return r'$&%#_{}"\'.contains(char);
  }
  
  bool isSpecialChar(String char) {
    return r'{},\\$^_[]'.contains(char);
  }
}
