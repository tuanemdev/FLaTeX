import 'dart:math' as math;
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
import 'package:flatex/model/nodes/symbol_node.dart';
import 'package:flatex/model/nodes/text_node.dart';
import 'package:flatex/renderer/layout/layout.dart';
import 'package:flatex/util/math_constants.dart';
import 'package:flutter/material.dart';

class LatexLayoutBuilder implements LaTeXNodeVisitor<LayoutBox> {
  final TextStyle baseTextStyle;
  final TextStyle mathStyle;
  final double fontSize;
  final double baselineOffset;
  final Map<String, String> symbolMap;
  final double scriptScaleFactor;
  final double fractionLineThickness;
  final double fractionGap;
  final double superscriptShift;
  final double subscriptShift;
  final double matrixCellPadding;

  LatexLayoutBuilder({
    required this.baseTextStyle,
    required this.mathStyle,
    this.fontSize = 16.0,
    this.baselineOffset = 0.0,
    this.scriptScaleFactor = 0.7,
    this.fractionLineThickness = 1.0,
    this.fractionGap = 4.0,
    this.superscriptShift = 7.0,
    this.subscriptShift = 5.0,
    this.matrixCellPadding = 5.0,
  }) : symbolMap = _buildSymbolMap();

  @override
  LayoutBox visitTextNode(TextNode node) {
    // Check if this is a mathematical operator (=, +, -, etc.)
    if (_isMathOperator(node.text.trim())) {
      // Use special spacing for math operators
      final spacedText = ' ${node.text.trim()} '; // Ensure proper spacing
      final textPainter = TextPainter(
        text: TextSpan(text: spacedText, style: mathStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      return TextLayoutBox(
        text: spacedText,
        style: mathStyle,
        bounds: Rect.fromLTWH(0, 0, textPainter.width, textPainter.height),
      );
    } 
    
    // Regular text handling
    final textPainter = TextPainter(
      text: TextSpan(text: node.text, style: baseTextStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    return TextLayoutBox(
      text: node.text,
      style: baseTextStyle,
      bounds: Rect.fromLTWH(0, 0, textPainter.width, textPainter.height),
    );
  }

  // Helper method to check if text is a math operator
  bool _isMathOperator(String text) {
    return text == "=" || text == "+" || text == "-" || text == "<" || 
           text == ">" || text == "≤" || text == "≥" || text == "≠" || 
           text == "≈" || text == "~";
  }

  @override
  LayoutBox visitMathNode(MathNode node) {
    final style =
        node.isDisplayMode
            ? mathStyle.copyWith(fontSize: fontSize * 1.2)
            : mathStyle;

    final LatexLayoutBuilder childBuilder = LatexLayoutBuilder(
      baseTextStyle: baseTextStyle,
      mathStyle: style,
      fontSize: fontSize,
      baselineOffset: baselineOffset,
      scriptScaleFactor: scriptScaleFactor,
      fractionLineThickness: fractionLineThickness,
      fractionGap: fractionGap,
      superscriptShift: superscriptShift,
      subscriptShift: subscriptShift,
      matrixCellPadding: matrixCellPadding,
    );

    final childBoxes =
        node.children.map((child) => child.accept(childBuilder)).toList();

    double totalWidth = 0;
    double maxHeight = 0;

    for (final box in childBoxes) {
      totalWidth += box.width;
      maxHeight = math.max(maxHeight, box.height);
    }

    double currentX = 0;
    for (final box in childBoxes) {
      final yOffset = (maxHeight - box.height) / 2;
      box.translate(Offset(currentX, yOffset));
      currentX += box.width;
    }

    return LayoutBox(
      bounds: Rect.fromLTWH(0, 0, totalWidth, maxHeight),
      children: childBoxes,
    );
  }

  @override
  LayoutBox visitGroupNode(GroupNode node) {
    final childBoxes =
        node.children.map((child) => child.accept(this)).toList();

    double totalWidth = 0;
    double maxHeight = 0;

    for (final box in childBoxes) {
      totalWidth += box.width;
      maxHeight = math.max(maxHeight, box.height);
    }

    double currentX = 0;
    for (final box in childBoxes) {
      final yOffset = (maxHeight - box.height) / 2;
      box.translate(Offset(currentX, yOffset));
      currentX += box.width;
    }

    return LayoutBox(
      bounds: Rect.fromLTWH(0, 0, totalWidth, maxHeight),
      children: childBoxes,
    );
  }

  @override
  LayoutBox visitCommandNode(CommandNode node) {
    switch (node.name) {
      case '\\frac':
        if (node.arguments.length >= 2) {
          return _buildFraction(node.arguments[0], node.arguments[1]);
        }
        break;
      case '\\sqrt':
        if (node.arguments.isNotEmpty) {
          return _buildSquareRoot(node.arguments[0]);
        }
        break;
      case '\\sum':
        return _buildSum(node);
      case '\\text':
        if (node.arguments.isNotEmpty) {
          return _buildText(node.arguments[0]);
        }
        break;
      default:
        final symbolName = node.name.substring(1);
        if (symbolMap.containsKey(symbolName)) {
          return _buildSymbol(symbolName);
        }
    }

    final childBoxes = node.arguments.map((arg) => arg.accept(this)).toList();

    double totalWidth = 0;
    double maxHeight = 0;

    for (final box in childBoxes) {
      totalWidth += box.width;
      maxHeight = math.max(maxHeight, box.height);
    }

    double currentX = 0;
    for (final box in childBoxes) {
      final yOffset = (maxHeight - box.height) / 2;
      box.translate(Offset(currentX, yOffset));
      currentX += box.width;
    }

    return LayoutBox(
      bounds: Rect.fromLTWH(0, 0, totalWidth, maxHeight),
      children: childBoxes,
    );
  }

  @override
  LayoutBox visitEnvironmentNode(EnvironmentNode node) {
    switch (node.name) {
      case 'matrix':
      case 'pmatrix':
      case 'bmatrix':
      case 'vmatrix':
        return _buildMatrix(node);
      default:
        final childBoxes =
            node.content.map((child) => child.accept(this)).toList();

        double totalWidth = 0;
        double maxHeight = 0;

        for (final box in childBoxes) {
          totalWidth += box.width;
          maxHeight = math.max(maxHeight, box.height);
        }

        double currentX = 0;
        for (final box in childBoxes) {
          final yOffset = (maxHeight - box.height) / 2;
          box.translate(Offset(currentX, yOffset));
          currentX += box.width;
        }

        return LayoutBox(
          bounds: Rect.fromLTWH(0, 0, totalWidth, maxHeight),
          children: childBoxes,
        );
    }
  }

  @override
  LayoutBox visitSymbolNode(SymbolNode node) {
    return _buildSymbol(node.name);
  }

  @override
  LayoutBox visitFractionNode(FractionNode node) {
    return _buildFraction(node.numerator, node.denominator);
  }

  @override
  LayoutBox visitSuperscriptNode(SuperscriptNode node) {
    // Check if base is a subscript node (for combined sub/superscript)
    if (node.base is SubscriptNode && _isLargeOperator((node.base as SubscriptNode).base)) {
      // Both subscript and superscript on a large operator
      final baseNode = (node.base as SubscriptNode).base;
      final subscript = (node.base as SubscriptNode).subscript;
      final superscript = node.exponent;

      final baseBox = baseNode.accept(this);

      final LatexLayoutBuilder scriptBuilder = LatexLayoutBuilder(
        baseTextStyle: baseTextStyle.copyWith(fontSize: fontSize * scriptScaleFactor),
        mathStyle: mathStyle.copyWith(fontSize: fontSize * scriptScaleFactor),
        fontSize: fontSize * scriptScaleFactor,
      );
      final subBox = subscript.accept(scriptBuilder);
      final supBox = superscript.accept(scriptBuilder);

      // Stack: superscript above, base, subscript below
      final gap = 2.0;
      final width = [
        baseBox.width,
        subBox.width,
        supBox.width,
      ].reduce(math.max);

      double y = 0;
      supBox.translate(Offset((width - supBox.width) / 2, y));
      y += supBox.height + gap;
      baseBox.translate(Offset((width - baseBox.width) / 2, y));
      y += baseBox.height + gap;
      subBox.translate(Offset((width - subBox.width) / 2, y));

      final totalHeight = supBox.height + gap + baseBox.height + gap + subBox.height;

      return LayoutBox(
        bounds: Rect.fromLTWH(0, 0, width, totalHeight),
        children: [supBox, baseBox, subBox],
      );
    }

    // Large operator with only superscript
    if (_isLargeOperator(node.base)) {
      final baseBox = node.base.accept(this);
      final LatexLayoutBuilder scriptBuilder = LatexLayoutBuilder(
        baseTextStyle: baseTextStyle.copyWith(fontSize: fontSize * scriptScaleFactor),
        mathStyle: mathStyle.copyWith(fontSize: fontSize * scriptScaleFactor),
        fontSize: fontSize * scriptScaleFactor,
      );
      final supBox = node.exponent.accept(scriptBuilder);

      final gap = 2.0;
      final width = math.max(baseBox.width, supBox.width);
      supBox.translate(Offset((width - supBox.width) / 2, 0));
      baseBox.translate(Offset((width - baseBox.width) / 2, supBox.height + gap));
      final totalHeight = supBox.height + gap + baseBox.height;

      return LayoutBox(
        bounds: Rect.fromLTWH(0, 0, width, totalHeight),
        children: [supBox, baseBox],
      );
    }

    // Special handling for sum superscripts
    if (node.base is CommandNode && (node.base as CommandNode).name == '\\sum') {
      return _buildSum(node.base as CommandNode);
    }
    
    // Handle normal superscripts
    final baseBox = node.base.accept(this);

    final LatexLayoutBuilder smallerBuilder = LatexLayoutBuilder(
      baseTextStyle: baseTextStyle.copyWith(
        fontSize: fontSize * scriptScaleFactor,
      ),
      mathStyle: mathStyle.copyWith(fontSize: fontSize * scriptScaleFactor),
      fontSize: fontSize * scriptScaleFactor,
    );

    final exponentBox = node.exponent.accept(smallerBuilder);

    // Swift positioning for superscript - higher and more to the right
    exponentBox.translate(Offset(
      baseBox.width - exponentBox.width * 0.1, 
      -exponentBox.height * 1.1
    ));

    // Swift uses more width to ensure proper spacing
    final width = math.max(baseBox.width, baseBox.width * 0.9 + exponentBox.width);
    final height = baseBox.height + exponentBox.height * 0.8;

    return LayoutBox(
      bounds: Rect.fromLTWH(0, 0, width, height),
      children: [baseBox, exponentBox],
    );
  }

  @override
  LayoutBox visitSubscriptNode(SubscriptNode node) {
    // Large operator with only subscript
    if (_isLargeOperator(node.base)) {
      final baseBox = node.base.accept(this);
      final LatexLayoutBuilder scriptBuilder = LatexLayoutBuilder(
        baseTextStyle: baseTextStyle.copyWith(fontSize: fontSize * scriptScaleFactor),
        mathStyle: mathStyle.copyWith(fontSize: fontSize * scriptScaleFactor),
        fontSize: fontSize * scriptScaleFactor,
      );
      final subBox = node.subscript.accept(scriptBuilder);

      final gap = 2.0;
      final width = math.max(baseBox.width, subBox.width);
      baseBox.translate(Offset((width - baseBox.width) / 2, 0));
      subBox.translate(Offset((width - subBox.width) / 2, baseBox.height + gap));
      final totalHeight = baseBox.height + gap + subBox.height;

      return LayoutBox(
        bounds: Rect.fromLTWH(0, 0, width, totalHeight),
        children: [baseBox, subBox],
      );
    }

    // Special handling for sum subscripts
    if (node.base is CommandNode && (node.base as CommandNode).name == '\\sum') {
      return _buildSum(node.base as CommandNode);
    }
    
    // Handle normal subscripts
    final baseBox = node.base.accept(this);

    final LatexLayoutBuilder smallerBuilder = LatexLayoutBuilder(
      baseTextStyle: baseTextStyle.copyWith(
        fontSize: fontSize * scriptScaleFactor,
      ),
      mathStyle: mathStyle.copyWith(fontSize: fontSize * scriptScaleFactor),
      fontSize: fontSize * scriptScaleFactor,
    );

    final subscriptBox = node.subscript.accept(smallerBuilder);

    // Swift positioning for subscript - lower and more to the right
    subscriptBox.translate(Offset(
      baseBox.width - subscriptBox.width * 0.1, 
      baseBox.height * 0.4
    ));

    // Swift uses slightly more width and height
    final width = math.max(baseBox.width, baseBox.width * 0.9 + subscriptBox.width);
    final height = baseBox.height + subscriptBox.height * 0.6;

    return LayoutBox(
      bounds: Rect.fromLTWH(0, 0, width, height),
      children: [baseBox, subscriptBox],
    );
  }

  @override
  LayoutBox visitMatrixNode(MatrixNode node) {
    return _buildMatrixFromCells(node.type, node.cells);
  }

  @override
  LayoutBox visitErrorNode(ErrorNode node) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: "Error: ${node.message}",
        style: baseTextStyle.copyWith(color: Colors.red),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return TextLayoutBox(
      text: "Error: ${node.message}",
      style: baseTextStyle.copyWith(color: Colors.red),
      bounds: Rect.fromLTWH(0, 0, textPainter.width, textPainter.height),
    );
  }

  LayoutBox _buildFraction(LaTeXNode numerator, LaTeXNode denominator) {
    final numeratorBox = numerator.accept(this);
    final denominatorBox = denominator.accept(this);

    // Determine if we're in display mode based on fontSize
    final isDisplayStyle = fontSize >= 14.0;
    
    // Calculate constants according to the OpenType MATH specification
    final ruleThickness = MathConstants.fractionRuleThickness(fontSize);
    
    // Calculate gaps based on display style
    final numGap = isDisplayStyle ? 
        MathConstants.fractionNumeratorDisplayStyleGapMin(fontSize) : 
        MathConstants.fractionNumeratorGapMin(fontSize);
    final denomGap = isDisplayStyle ?
        MathConstants.fractionDenominatorDisplayStyleGapMin(fontSize) :
        MathConstants.fractionDenominatorGapMin(fontSize);
    
    // Ensure minimum width for the fraction
    final fractionWidth = math.max(numeratorBox.width, denominatorBox.width) * 1.05;

    // Position numerator - center horizontally
    numeratorBox.translate(Offset((fractionWidth - numeratorBox.width) / 2, 0));
    
    // Calculate vertical position for denominator
    // There should be: numerator + numGap + ruleThickness + denomGap + denominator
    final totalGap = numGap + ruleThickness + denomGap;
    final denomYOffset = numeratorBox.height + totalGap;
    
    // Position denominator - center horizontally and place below with proper gap
    denominatorBox.translate(
      Offset((fractionWidth - denominatorBox.width) / 2, denomYOffset)
    );

    // Calculate total fraction height
    final totalHeight = numeratorBox.height + totalGap + denominatorBox.height;

    return FractionLayoutBox(
      bounds: Rect.fromLTWH(0, 0, fractionWidth, totalHeight),
      children: [numeratorBox, denominatorBox],
      lineThickness: ruleThickness,
      isDisplayStyle: isDisplayStyle,
    );
  }

  LayoutBox _buildSquareRoot(LaTeXNode content) {
    final contentBox = content.accept(this);
    
    // Determine if we're in display mode
    final isDisplayStyle = fontSize >= 14.0;
    
    // Calculate proper layout parameters for the square root
    final ruleThickness = MathConstants.radicalRuleThickness(fontSize);
    final verticalGap = isDisplayStyle ? 
        MathConstants.radicalDisplayStyleVerticalGap(fontSize) : 
        MathConstants.radicalVerticalGap(fontSize);
    
    // Calculate the width needed for the radical symbol
    // Using a proportion of the content height
    final contentHeight = contentBox.height;
    final radicalWidth = contentHeight * 0.4;
    
    // Position content to allow space for the radical
    // Add a horizontal gap to ensure the content doesn't touch the radical
    final horizontalGap = fontSize * 0.1;
    contentBox.translate(Offset(radicalWidth + horizontalGap, 0));
    
    // Calculate the total bounds of the sqrt layout
    final totalWidth = contentBox.width + radicalWidth + horizontalGap;
    final totalHeight = math.max(contentBox.height, contentHeight + verticalGap * 2);
    
    return SqrtLayoutBox(
      bounds: Rect.fromLTWH(0, 0, totalWidth, totalHeight),
      children: [contentBox],
      lineThickness: ruleThickness,
      lineColor: mathStyle.color ?? Colors.black,
      symbolStyle: mathStyle,
      isDisplayStyle: isDisplayStyle,
    );
  }

  LayoutBox _buildSum(CommandNode node) {
    // Get the sum symbol
    final sumSymbol = symbolMap['sum'] ?? '∑';
    
    // Create a text painter for the symbol to measure it
    final isDisplayStyle = fontSize >= 16.0;
    final symbolSize = isDisplayStyle ? fontSize * 2.0 : fontSize * 1.7;
    
    final sumPainter = TextPainter(
      text: TextSpan(text: sumSymbol, style: mathStyle.copyWith(
        fontSize: symbolSize,
        fontWeight: FontWeight.w500,
      )),
      textDirection: TextDirection.ltr,
    )..layout();
    
    // Calculate proper width with standard proportions
    double width = sumPainter.width * 1.3;
    
    // Handle subscript and superscript if present
    LayoutBox? subBox, supBox;
    double subSupWidth = 0;
    bool hasLimits = false;
    
    final scriptBuilder = LatexLayoutBuilder(
      baseTextStyle: baseTextStyle.copyWith(fontSize: fontSize * MathConstants.scriptScaleFactor),
      mathStyle: mathStyle.copyWith(fontSize: fontSize * MathConstants.scriptScaleFactor),
      fontSize: fontSize * MathConstants.scriptScaleFactor,
      baselineOffset: baselineOffset,
      scriptScaleFactor: scriptScaleFactor,
      fractionLineThickness: fractionLineThickness,
      fractionGap: fractionGap,
      superscriptShift: superscriptShift,
      subscriptShift: subscriptShift,
      matrixCellPadding: matrixCellPadding,
    );
    
    // Process limits
    if (node.arguments.isNotEmpty) {
      for (var arg in node.arguments) {
        // Handle subscripts/superscripts for large operators
        if (arg is SubscriptNode && 
            (arg.base is TextNode && (arg.base as TextNode).text.isEmpty)) {
          subBox = arg.subscript.accept(scriptBuilder);
          if (subBox != null) {
            subSupWidth = math.max(subSupWidth, subBox.width);
          }
          hasLimits = true;
        } else if (arg is SuperscriptNode && 
                  (arg.base is TextNode && (arg.base as TextNode).text.isEmpty)) {
          supBox = arg.exponent.accept(scriptBuilder);
          if (supBox != null) {
            subSupWidth = math.max(subSupWidth, supBox.width);
          }
          hasLimits = true;
        }
      }
    }
    
    // Ensure proper width for the whole expression
    width = math.max(width, subSupWidth * 1.2);
    final children = <LayoutBox>[];
    double totalHeight = sumPainter.height;
    
    // Calculate standard gaps
    final upperLimitGap = MathConstants.upperLimitGapMin(fontSize);
    final lowerLimitGap = MathConstants.lowerLimitGapMin(fontSize);
    
    // Position limits according to OpenType MATH specifications
    if (isDisplayStyle) {
      // Display style - limits above and below
      if (supBox != null) {
        // Position superscript at the top with proper gap
        supBox.translate(Offset((width - supBox.width) / 2, 0));
        children.add(supBox);
        totalHeight = supBox.height + upperLimitGap;
      }
      
      // Add height for the symbol itself
      totalHeight += sumPainter.height;
      
      if (subBox != null) {
        // Position subscript below with proper gap
        subBox.translate(Offset(
          (width - subBox.width) / 2,
          totalHeight + lowerLimitGap
        ));
        children.add(subBox);
        totalHeight += subBox.height + lowerLimitGap;
      }
    } else {
      // Inline style - limits as subscripts/superscripts
      // Just use standard sum height
      totalHeight = sumPainter.height;
      
      // Position limits to the right with proper offsets
      if (supBox != null) {
        // Position as proper superscript
        supBox.translate(Offset(
          width * 0.7,
          MathConstants.superscriptShiftUp(fontSize)
        ));
        children.add(supBox);
      }
      
      if (subBox != null) {
        // Position as proper subscript
        subBox.translate(Offset(
          width * 0.7,
          sumPainter.height - MathConstants.subscriptShiftDown(fontSize)
        ));
        children.add(subBox);
      }
      
      // Adjust width if needed for side scripts
      if (supBox != null || subBox != null) {
        width += subSupWidth * 0.8;
      }
    }
    
    return SumLayoutBox(
      symbol: sumSymbol,
      style: mathStyle.copyWith(fontSize: symbolSize),
      bounds: Rect.fromLTWH(0, 0, width, totalHeight),
      children: children,
      hasLimits: hasLimits,
      isDisplayStyle: isDisplayStyle,
    );
  }

  LayoutBox _buildText(LaTeXNode content) {
    final LatexLayoutBuilder textStyleBuilder = LatexLayoutBuilder(
      baseTextStyle: baseTextStyle,
      mathStyle:
          baseTextStyle,
      fontSize: fontSize,
      baselineOffset: baselineOffset,
      scriptScaleFactor: scriptScaleFactor,
      fractionLineThickness: fractionLineThickness,
      fractionGap: fractionGap,
      superscriptShift: superscriptShift,
      subscriptShift: subscriptShift,
      matrixCellPadding: matrixCellPadding,
    );

    return content.accept(textStyleBuilder);
  }

  LayoutBox _buildSymbol(String symbolName) {
    final symbolText = symbolMap[symbolName] ?? symbolName;

    final textPainter = TextPainter(
      text: TextSpan(text: symbolText, style: mathStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    return SymbolLayoutBox(
      symbol: symbolText,
      style: mathStyle,
      bounds: Rect.fromLTWH(0, 0, textPainter.width, textPainter.height),
    );
  }

  LayoutBox _buildMatrix(EnvironmentNode node) {
    if (node.content.isEmpty) {
      return LayoutBox(bounds: Rect.fromLTWH(0, 0, 10, 10));
    }

    List<List<LaTeXNode>> cells = [];
    List<LaTeXNode> currentRow = [];

    for (final child in node.content) {
      if (child is MatrixNode) {
        return _buildMatrixFromCells(node.name, child.cells);
      } else if (child is TextNode && child.text.trim() == '\\\\') {
        if (currentRow.isNotEmpty) {
          cells.add(currentRow);
          currentRow = [];
        }
      } else if (child is TextNode && child.text.trim() == '&') {
      } else {
        currentRow.add(child);
      }
    }

    if (currentRow.isNotEmpty) {
      cells.add(currentRow);
    }

    return _buildMatrixFromCells(node.name, cells);
  }

  LayoutBox _buildMatrixFromCells(
    String matrixType,
    List<List<LaTeXNode>> cells,
  ) {
    if (cells.isEmpty) {
      return LayoutBox(bounds: Rect.fromLTWH(0, 0, 10, 10));
    }

    final rowCount = cells.length;
    int colCount = 0;
    for (final row in cells) {
      colCount = math.max(colCount, row.length);
    }

    final cellBoxes = List.generate(
      rowCount,
      (_) => List<LayoutBox?>.filled(colCount, null),
    );

    final colWidths = List<double>.filled(colCount, 0);
    final rowHeights = List<double>.filled(rowCount, 0);

    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < cells[i].length; j++) {
        final cellBox = cells[i][j].accept(this);
        cellBoxes[i][j] = cellBox;

        colWidths[j] = math.max(
          colWidths[j],
          cellBox.width + matrixCellPadding * 2,
        );
        rowHeights[i] = math.max(
          rowHeights[i],
          cellBox.height + matrixCellPadding * 2,
        );
      }
    }

    double totalWidth = colWidths.fold(0, (sum, width) => sum + width);
    double totalHeight = rowHeights.fold(0, (sum, height) => sum + height);

    final bracketPadding = 10.0;
    totalWidth += bracketPadding * 2;

    final allCells = <LayoutBox>[];
    double yPos = 0;

    for (int i = 0; i < rowCount; i++) {
      double xPos = bracketPadding;

      for (int j = 0; j < cells[i].length; j++) {
        final cellBox = cellBoxes[i][j];
        if (cellBox != null) {
          final xOffset = xPos + (colWidths[j] - cellBox.width) / 2;
          final yOffset = yPos + (rowHeights[i] - cellBox.height) / 2;

          cellBox.translate(Offset(xOffset, yOffset));
          allCells.add(cellBox);
        }

        xPos += colWidths[j];
      }

      yPos += rowHeights[i];
    }

    return MatrixLayoutBox(
      type: matrixType,
      bounds: Rect.fromLTWH(0, 0, totalWidth, totalHeight),
      children: allCells,
    );
  }

  static Map<String, String> _buildSymbolMap() {
    return {
      'alpha': 'α',
      'beta': 'β',
      'gamma': 'γ',
      'delta': 'δ',
      'epsilon': 'ε',
      'zeta': 'ζ',
      'eta': 'η',
      'theta': 'θ',
      'iota': 'ι',
      'kappa': 'κ',
      'lambda': 'λ',
      'mu': 'μ',
      'nu': 'ν',
      'xi': 'ξ',
      'omicron': 'ο',
      'pi': 'π',
      'rho': 'ρ',
      'sigma': 'σ',
      'tau': 'τ',
      'upsilon': 'υ',
      'phi': 'φ',
      'chi': 'χ',
      'psi': 'ψ',
      'omega': 'ω',
      'Gamma': 'Γ',
      'Delta': 'Δ',
      'Theta': 'Θ',
      'Lambda': 'Λ',
      'Xi': 'Ξ',
      'Pi': 'Π',
      'Sigma': 'Σ',
      'Phi': 'Φ',
      'Psi': 'Ψ',
      'Omega': 'Ω',
      'sum': '∑',
      'prod': '∏',
      'int': '∫',
      'partial': '∂',
      'infty': '∞',
      'pm': '±',
      'mp': '∓',
      'times': '×',
      'div': '÷',
      'cdot': '⋅',
      'ldots': '…',
      'cdots': '⋯',
      'vdots': '⋮',
      'ddots': '⋱',
      'leq': '≤',
      'geq': '≥',
      'neq': '≠',
      'approx': '≈',
      'equiv': '≡',
      'propto': '∝',
      'sim': '∼',
      'cong': '≅',
      'in': '∈',
      'notin': '∉',
      'subset': '⊂',
      'supset': '⊃',
      'subseteq': '⊆',
      'supseteq': '⊇',
      'cap': '∩',
      'cup': '∪',
      'forall': '∀',
      'exists': '∃',
      'nexists': '∄',
      'rightarrow': '→',
      'leftarrow': '←',
      'Rightarrow': '⇒',
      'Leftarrow': '⇐',
      'uparrow': '↑',
      'downarrow': '↓',
      'mapsto': '↦',
      'prime': '′',
      'nabla': '∇',
      'emptyset': '∅',
      'angle': '∠',
      'surd': '√',
      'Box': '□',
      'diamond': '⋄',
      'triangle': '△',
      'therefore': '∴',
      'because': '∵',
      'vartheta': 'ϑ',
      'varpi': 'ϖ',
      'varrho': 'ϱ',
      'varsigma': 'ς',
      'varphi': 'ϕ',
      'setminus': '∖',
      'aleph': 'ℵ',
      'neg': '¬',
      'land': '∧',
      'lor': '∨',
      'implies': '⟹',
      'iff': '⟺',
      'leftrightarrow': '↔',
      'Leftrightarrow': '⇔',
      'Uparrow': '⇑',
      'Downarrow': '⇓',
      'hbar': 'ℏ',
      'ell': 'ℓ',
      'wp': '℘',
      'Re': 'ℜ',
      'Im': 'ℑ',
      'oplus': '⊕',
      'otimes': '⊗',
      'perp': '⊥',
      'parallel': '∥',
      'asymp': '≍',
      'dagger': '†',
      'ddagger': '‡',
      'prec': '≺',
      'succ': '≻',
      'preceq': '⪯',
      'succeq': '⪰',
      'lim': 'lim',
    };
  }

  // Helper: check if a node is a large operator (lim, sum, int, prod, etc.)
  bool _isLargeOperator(LaTeXNode node) {
    if (node is CommandNode) {
      final name = node.name.replaceFirst(r'\', '');
      return [
        'lim', 'sum', 'prod', 'int', 'limsup', 'liminf', 'max', 'min', 'sup', 'inf'
      ].contains(name);
    }
    return false;
  }
}
