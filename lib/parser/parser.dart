import 'package:flatex/model/node.dart';
import 'package:flatex/model/nodes/command_node.dart';
import 'package:flatex/model/nodes/environment_node.dart';
import 'package:flatex/model/nodes/error_node.dart';
import 'package:flatex/model/nodes/fraction_node.dart';
import 'package:flatex/model/nodes/group_node.dart';
import 'package:flatex/model/nodes/math_node.dart';
import 'package:flatex/model/nodes/matrix_node.dart';
import 'package:flatex/model/nodes/subscript_node.dart';
import 'package:flatex/model/nodes/superscript_node.dart';
import 'package:flatex/model/nodes/text_node.dart';
import 'package:flatex/parser/lexer.dart';
import 'package:flatex/parser/token.dart';

final class LaTeXParser {
  final LaTeXLexer lexer;
  Token currentToken;

  LaTeXParser(String input)
    : lexer = LaTeXLexer(input),
      currentToken = Token(type: TokenType.eof, value: '', position: 0) {
    // Initialize with the first token
    advance();
  }

  void advance() {
    currentToken = lexer.nextToken();
  }

  bool match(TokenType type) {
    if (currentToken.type == type) {
      advance();
      return true;
    }
    return false;
  }

  void expect(TokenType type, String errorMessage) {
    if (currentToken.type != type) {
      throw FormatException(
        '$errorMessage, got ${currentToken.type} at position ${currentToken.position}',
      );
    }
    advance();
  }

  LaTeXNode parse() {
    return parseDocument();
  }

  LaTeXNode parseDocument() {
    final startPos = currentToken.position;
    final nodes = <LaTeXNode>[];

    while (currentToken.type != TokenType.eof) {
      nodes.add(parseExpression());
    }

    return GroupNode(
      children: nodes,
      startPosition: startPos,
      endPosition: lexer.position,
    );
  }

  LaTeXNode parseExpression() {
    // Skip any whitespace before starting a new expression
    while (currentToken.type == TokenType.whitespace) {
      advance();
    }

    LaTeXNode node;
    final initialPosition = currentToken.position;

    switch (currentToken.type) {
      case TokenType.text:
        node = parseText();
        break;
      case TokenType.command:
        node = parseCommand();
        break;
      case TokenType.beginGroup:
        node = parseGroup();
        break;
      case TokenType.beginMath:
        node = parseMath(false);
        break;
      case TokenType.beginDisplayMath:
        node = parseMath(true);
        break;
      case TokenType.beginEnvironment:
        node = parseEnvironment();
        break;
      case TokenType.superscript:
        // Direct superscript handling (like ^2 without a base)
        node = parseSuperscript();
        break;
      case TokenType.subscript:
        // Direct subscript handling (like _i without a base)
        node = parseSubscript();
        break;
      case TokenType.eof:
        return ErrorNode(
          message: 'Unexpected end of file',
          startPosition: initialPosition,
          endPosition: initialPosition + 1,
        );
      default:
        final errorPos = currentToken.position;
        final errorToken = currentToken;
        advance();
        return ErrorNode(
          message: 'Unexpected token: ${errorToken.type} (${errorToken.value})',
          startPosition: errorPos,
          endPosition:
              errorPos +
              (errorToken.value.isNotEmpty ? errorToken.value.length : 1),
        );
    }

    // Handle superscript/subscript after the base node
    while (currentToken.type == TokenType.superscript ||
        currentToken.type == TokenType.subscript) {
      if (currentToken.type == TokenType.superscript) {
        advance();
        // Skip any whitespace after the superscript symbol
        while (currentToken.type == TokenType.whitespace) {
          advance();
        }
        final exponent =
            currentToken.type == TokenType.beginGroup
                ? parseGroup()
                : parseExpression();
        node = SuperscriptNode(
          base: node,
          exponent: exponent,
          startPosition: node.startPosition,
          endPosition: exponent.endPosition,
        );
      } else if (currentToken.type == TokenType.subscript) {
        advance();
        // Skip any whitespace after the subscript symbol
        while (currentToken.type == TokenType.whitespace) {
          advance();
        }
        final subscript =
            currentToken.type == TokenType.beginGroup
                ? parseGroup()
                : parseExpression();
        node = SubscriptNode(
          base: node,
          subscript: subscript,
          startPosition: node.startPosition,
          endPosition: subscript.endPosition,
        );
      }
    }

    // Skip any whitespace after the expression
    while (currentToken.type == TokenType.whitespace) {
      advance();
    }

    return node;
  }

  TextNode parseText() {
    final token = currentToken;
    advance();
    return TextNode(
      text: token.value,
      startPosition: token.position,
      endPosition: token.position + token.value.length,
    );
  }

  LaTeXNode parseCommand() {
    final startPos = currentToken.position;
    final commandName = currentToken.value;
    advance();

    // Skip whitespace after the command name
    while (currentToken.type == TokenType.whitespace) {
      advance();
    }

    final options = <String>[];
    if (currentToken.type == TokenType.beginOptions) {
      advance();

      final optionBuilder = StringBuffer();
      while (currentToken.type != TokenType.endOptions &&
          currentToken.type != TokenType.eof) {
        optionBuilder.write(currentToken.value);
        advance();
      }

      options.add(optionBuilder.toString());
      expect(TokenType.endOptions, 'Expected closing bracket for options');
    }

    final arguments = <LaTeXNode>[];
    while (currentToken.type == TokenType.beginGroup) {
      arguments.add(parseGroup());
    }

    // Special handling for \frac
    if (commandName == '\\frac') {
      if (arguments.length >= 2) {
        return FractionNode(
          numerator: arguments[0],
          denominator: arguments[1],
          startPosition: startPos,
          endPosition: lexer.position,
        );
      }
    }

    return CommandNode(
      name: commandName,
      options: options,
      arguments: arguments,
      startPosition: startPos,
      endPosition: lexer.position,
    );
  }

  GroupNode parseGroup() {
    final startPos = currentToken.position;
    expect(TokenType.beginGroup, 'Expected opening brace');

    final children = <LaTeXNode>[];
    if (currentToken.type == TokenType.endGroup) {
      expect(TokenType.endGroup, 'Expected closing brace');
      return GroupNode(
        children: children,
        startPosition: startPos,
        endPosition: lexer.position,
      );
    }
    while (currentToken.type != TokenType.endGroup &&
        currentToken.type != TokenType.eof) {
      children.add(parseExpression());
    }

    expect(TokenType.endGroup, 'Expected closing brace');

    return GroupNode(
      children: children,
      startPosition: startPos,
      endPosition: lexer.position,
    );
  }

  LaTeXNode parseMath(bool isDisplayMode) {
    final startPos = currentToken.position;

    final beginType =
        isDisplayMode ? TokenType.beginDisplayMath : TokenType.beginMath;
    final endType =
        isDisplayMode ? TokenType.endDisplayMath : TokenType.endMath;
    final matchingDelimiter =
        isDisplayMode
            ? (currentToken.value == r'$$' ? r'$$' : '\\]')
            : (currentToken.value == r'$' ? r'$' : '\\)');

    expect(beginType, 'Expected math delimiter');

    final children = <LaTeXNode>[];
    while (currentToken.type != endType && currentToken.type != TokenType.eof) {
      children.add(parseExpression());
    }

    if (currentToken.type == TokenType.eof) {
      return ErrorNode(
        message: 'Unterminated math expression, expected $matchingDelimiter',
        partialNode: MathNode(
          children: children,
          isDisplayMode: isDisplayMode,
          startPosition: startPos,
          endPosition: lexer.position,
        ),
        startPosition: startPos,
        endPosition: lexer.position,
      );
    }

    expect(endType, 'Expected closing math delimiter');

    return MathNode(
      children: children,
      isDisplayMode: isDisplayMode,
      startPosition: startPos,
      endPosition: lexer.position,
    );
  }

  LaTeXNode parseEnvironment() {
    final startPos = currentToken.position;
    expect(TokenType.beginEnvironment, 'Expected \\begin');

    expect(TokenType.beginGroup, 'Expected { after \\begin');
    final nameBuilder = StringBuffer();
    while (currentToken.type != TokenType.endGroup &&
        currentToken.type != TokenType.eof) {
      nameBuilder.write(currentToken.value);
      advance();
    }
    final environmentName = nameBuilder.toString();
    expect(TokenType.endGroup, 'Expected } after environment name');

    final options = <String>[];
    if (currentToken.type == TokenType.beginOptions) {
      advance();
      final optionBuilder = StringBuffer();
      while (currentToken.type != TokenType.endOptions &&
          currentToken.type != TokenType.eof) {
        optionBuilder.write(currentToken.value);
        advance();
      }
      options.add(optionBuilder.toString());
      expect(TokenType.endOptions, 'Expected closing bracket for options');
    }

    final content = <LaTeXNode>[];

    // Special handling for matrix-like environments
    if (environmentName.contains('matrix')) {
      content.add(parseMatrixContent(environmentName));
    } else {
      // Parse until we find \end{same_name}
      while (!(currentToken.type == TokenType.endEnvironment) &&
          currentToken.type != TokenType.eof) {
        content.add(parseExpression());
      }
    }

    if (currentToken.type == TokenType.eof) {
      return ErrorNode(
        message: 'Unterminated environment, expected \\end{$environmentName}',
        partialNode: EnvironmentNode(
          name: environmentName,
          options: options,
          content: content,
          startPosition: startPos,
          endPosition: lexer.position,
        ),
        startPosition: startPos,
        endPosition: lexer.position,
      );
    }

    expect(TokenType.endEnvironment, 'Expected \\end');
    expect(TokenType.beginGroup, 'Expected { after \\end');

    final endNameBuilder = StringBuffer();
    while (currentToken.type != TokenType.endGroup &&
        currentToken.type != TokenType.eof) {
      endNameBuilder.write(currentToken.value);
      advance();
    }

    final endName = endNameBuilder.toString();
    expect(TokenType.endGroup, 'Expected } after environment name');

    if (environmentName != endName) {
      return ErrorNode(
        message: 'Environment name mismatch: $environmentName vs $endName',
        startPosition: startPos,
        endPosition: lexer.position,
      );
    }

    return EnvironmentNode(
      name: environmentName,
      options: options,
      content: content,
      startPosition: startPos,
      endPosition: lexer.position,
    );
  }

  MatrixNode parseMatrixContent(String matrixType) {
    final startPos = currentToken.position;
    final cells = <List<LaTeXNode>>[];
    var currentRow = <LaTeXNode>[];

    while (!(currentToken.type == TokenType.endEnvironment) &&
        currentToken.type != TokenType.eof) {
      if (currentToken.value == '\\\\') {
        // End of row
        cells.add(currentRow);
        currentRow = <LaTeXNode>[];
        advance();
        continue;
      } else if (currentToken.type == TokenType.separator) {
        // End of cell
        advance();
        continue;
      }

      currentRow.add(parseExpression());

      if (currentToken.type == TokenType.separator) {
        advance();
      }
    }

    // Add the last row if not empty
    if (currentRow.isNotEmpty) {
      cells.add(currentRow);
    }

    return MatrixNode(
      type: matrixType,
      cells: cells,
      startPosition: startPos,
      endPosition: lexer.position,
    );
  }

  SuperscriptNode parseSuperscript() {
    final startPos = currentToken.position;
    expect(TokenType.superscript, 'Expected superscript');

    final exponent =
        currentToken.type == TokenType.beginGroup
            ? parseGroup()
            : parseExpression();

    return SuperscriptNode(
      base: TextNode(text: '', startPosition: startPos, endPosition: startPos),
      exponent: exponent,
      startPosition: startPos,
      endPosition: lexer.position,
    );
  }

  SubscriptNode parseSubscript() {
    final startPos = currentToken.position;
    expect(TokenType.subscript, 'Expected subscript');

    final subscript =
        currentToken.type == TokenType.beginGroup
            ? parseGroup()
            : parseExpression();

    return SubscriptNode(
      base: TextNode(text: '', startPosition: startPos, endPosition: startPos),
      subscript: subscript,
      startPosition: startPos,
      endPosition: lexer.position,
    );
  }
}
