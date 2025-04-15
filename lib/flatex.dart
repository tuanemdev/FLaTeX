import 'package:flutter/material.dart';

class LaTeX extends StatelessWidget {
  final String expression;
  final Color textColor;
  final Color backgroundColor;
  final double fontSize;
  final FontWeight fontWeight;
  final Alignment alignment;

  const LaTeX(
    this.expression, {
    super.key,
    this.textColor = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.normal,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      alignment: alignment,
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _renderExpression(context, constraints);
        },
      ),
    );
  }

  Widget _renderExpression(BuildContext context, BoxConstraints constraints) {
    final tokens = _tokenizeExpression(expression);
    return _buildExpressionWidget(context, tokens);
  }

  List<LatexToken> _tokenizeExpression(String expression) {
    List<LatexToken> tokens = [];
    
    // Tokenization logic
    int i = 0;
    while (i < expression.length) {
      if (expression[i] == '\\') {
        // Parse command
        if (i + 1 >= expression.length) {
          tokens.add(LatexToken(LatexTokenType.text, '\\'));
          i++;
          continue;
        }
        
        String command = '\\';
        i++;
        // Get command name
        while (i < expression.length && 
              (expression[i].contains(RegExp(r'[a-zA-Z]')) || expression[i] == '\\')) {
          command += expression[i];
          i++;
        }
        
        tokens.add(LatexToken(LatexTokenType.command, command));
      } else if (expression[i] == '{') {
        // Parse group
        i++;
        int braceCount = 1;
        String groupContent = '';
        
        while (i < expression.length && braceCount > 0) {
          if (expression[i] == '{') {
            braceCount++;
          } else if (expression[i] == '}') {
            braceCount--;
          }
          
          if (braceCount > 0) {
            groupContent += expression[i];
          }
          i++;
        }
        
        tokens.add(LatexToken(LatexTokenType.group, groupContent));
      } else if (expression[i] == '_' || expression[i] == '^') {
        // Subscript or superscript
        LatexTokenType type = expression[i] == '_' 
            ? LatexTokenType.subscript 
            : LatexTokenType.superscript;
        i++;
        
        // Parse the subscript/superscript content
        if (i < expression.length) {
          if (expression[i] == '{') {
            i++;
            int braceCount = 1;
            String content = '';
            
            while (i < expression.length && braceCount > 0) {
              if (expression[i] == '{') {
                braceCount++;
              } else if (expression[i] == '}') {
                braceCount--;
              }
              
              if (braceCount > 0) {
                content += expression[i];
              }
              i++;
            }
            
            tokens.add(LatexToken(type, content));
          } else {
            tokens.add(LatexToken(type, expression[i].toString()));
            i++;
          }
        }
      } else {
        // Regular text
        String text = '';
        while (i < expression.length && 
               !r'\_^{}\'.contains(expression[i])) {
          text += expression[i];
          i++;
        }
        tokens.add(LatexToken(LatexTokenType.text, text));
      }
    }
    
    return tokens;
  }

  Widget _buildExpressionWidget(BuildContext context, List<LatexToken> tokens) {
    List<Widget> children = [];
    
    for (int i = 0; i < tokens.length; i++) {
      LatexToken token = tokens[i];
      
      switch (token.type) {
        case LatexTokenType.text:
          children.add(
            Text(
              token.value,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          );
          break;
          
        case LatexTokenType.command:
          if (token.value == '\\frac') {
            // Need two groups for numerator and denominator
            if (i + 2 < tokens.length && 
                tokens[i + 1].type == LatexTokenType.group && 
                tokens[i + 2].type == LatexTokenType.group) {
              
              LatexToken numerator = tokens[i + 1];
              LatexToken denominator = tokens[i + 2];
              
              children.add(
                _buildFraction(
                  context,
                  _tokenizeExpression(numerator.value),
                  _tokenizeExpression(denominator.value),
                ),
              );
              
              i += 2; // Skip the next two tokens as we've consumed them
            }
          } else if (token.value == '\\sqrt') {
            // Square root
            if (i + 1 < tokens.length && tokens[i + 1].type == LatexTokenType.group) {
              LatexToken content = tokens[i + 1];
              
              children.add(
                _buildSquareRoot(
                  context,
                  _tokenizeExpression(content.value),
                ),
              );
              
              i++; // Skip the next token as we've consumed it
            }
          } else if (token.value == '\\sum') {
            // Summation
            children.add(_buildSummation(context));
            
            // Handle subscript and superscript if they exist
            int j = i + 1;
            LatexToken? subscript;
            LatexToken? superscript;
            
            while (j < tokens.length && 
                  (tokens[j].type == LatexTokenType.subscript || 
                   tokens[j].type == LatexTokenType.superscript)) {
              if (tokens[j].type == LatexTokenType.subscript) {
                subscript = tokens[j];
              } else {
                superscript = tokens[j];
              }
              j++;
            }
            
            if (subscript != null || superscript != null) {
              children.add(
                _buildSummationLimits(
                  context,
                  subscript != null ? _tokenizeExpression(subscript.value) : null,
                  superscript != null ? _tokenizeExpression(superscript.value) : null,
                ),
              );
              i = j - 1; // Update the index
            }
          } else if (token.value == '\\int') {
            // Integral
            children.add(_buildIntegral(context));
            
            // Handle subscript and superscript if they exist
            int j = i + 1;
            LatexToken? subscript;
            LatexToken? superscript;
            
            while (j < tokens.length && 
                  (tokens[j].type == LatexTokenType.subscript || 
                   tokens[j].type == LatexTokenType.superscript)) {
              if (tokens[j].type == LatexTokenType.subscript) {
                subscript = tokens[j];
              } else {
                superscript = tokens[j];
              }
              j++;
            }
            
            if (subscript != null || superscript != null) {
              children.add(
                _buildIntegralLimits(
                  context,
                  subscript != null ? _tokenizeExpression(subscript.value) : null,
                  superscript != null ? _tokenizeExpression(superscript.value) : null,
                ),
              );
              i = j - 1; // Update the index
            }
          } else if (token.value == '\\pm') {
            // Plus-minus symbol
            children.add(
              Text(
                '±',
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
            );
          } else {
            // Unhandled command, just show it as text
            children.add(
              Text(
                token.value,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
            );
          }
          break;
          
        case LatexTokenType.group:
          // Render the group content
          List<LatexToken> groupTokens = _tokenizeExpression(token.value);
          children.add(_buildExpressionWidget(context, groupTokens));
          break;
          
        case LatexTokenType.subscript:
          if (i > 0 && tokens[i - 1].type == LatexTokenType.text) {
            // Add subscript to the previous text
            children.add(
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    token.value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize * 0.7,
                      fontWeight: fontWeight,
                    ),
                  ),
                ],
              ),
            );
          }
          break;
          
        case LatexTokenType.superscript:
          if (i > 0) {
            // Add superscript
            children.add(
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    token.value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize * 0.7,
                      fontWeight: fontWeight,
                    ),
                  ),
                ],
              ),
            );
          }
          break;
      }
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
  
  Widget _buildFraction(
    BuildContext context, 
    List<LatexToken> numeratorTokens, 
    List<LatexToken> denominatorTokens
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildExpressionWidget(context, numeratorTokens),
        Container(
          height: 1.0,
          width: 40.0,
          color: textColor,
          margin: const EdgeInsets.symmetric(vertical: 2.0),
        ),
        _buildExpressionWidget(context, denominatorTokens),
      ],
    );
  }
  
  Widget _buildSquareRoot(BuildContext context, List<LatexToken> contentTokens) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: const Size(10, 20),
          painter: SquareRootPainter(textColor),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 1.0,
              width: 40.0,
              color: textColor,
            ),
            _buildExpressionWidget(context, contentTokens),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSummation(BuildContext context) {
    return Text(
      '∑',
      style: TextStyle(
        color: textColor,
        fontSize: fontSize * 1.5,
        fontWeight: fontWeight,
      ),
    );
  }
  
  Widget _buildSummationLimits(
    BuildContext context, 
    List<LatexToken>? lowerTokens, 
    List<LatexToken>? upperTokens
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (upperTokens != null)
          _buildExpressionWidget(
            context, upperTokens,
          ),
        const SizedBox(height: 2),
        if (lowerTokens != null)
          _buildExpressionWidget(
            context, lowerTokens,
          ),
      ],
    );
  }
  
  Widget _buildIntegral(BuildContext context) {
    return Text(
      '∫',
      style: TextStyle(
        color: textColor,
        fontSize: fontSize * 1.5,
        fontWeight: fontWeight,
      ),
    );
  }
  
  Widget _buildIntegralLimits(
    BuildContext context, 
    List<LatexToken>? lowerTokens, 
    List<LatexToken>? upperTokens
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (upperTokens != null)
          _buildExpressionWidget(
            context, upperTokens,
          ),
        const SizedBox(height: 2),
        if (lowerTokens != null)
          _buildExpressionWidget(
            context, lowerTokens,
          ),
      ],
    );
  }
}

enum LatexTokenType {
  text,
  command,
  group,
  subscript,
  superscript,
}

class LatexToken {
  final LatexTokenType type;
  final String value;
  
  LatexToken(this.type, this.value);
}

class SquareRootPainter extends CustomPainter {
  final Color color;
  
  SquareRootPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final Path path = Path()
      ..moveTo(0, size.height * 0.6)
      ..lineTo(size.width * 0.3, size.height)
      ..lineTo(size.width * 0.5, 0)
      ..lineTo(size.width, 0);
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}