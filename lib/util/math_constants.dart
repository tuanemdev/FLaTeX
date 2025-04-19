import 'package:flutter/material.dart';

/// Constants for mathematical typesetting based on OpenType MATH table specification
/// https://learn.microsoft.com/vi-vn/typography/opentype/spec/math
class MathConstants {
  // Private constructor to prevent instantiation
  MathConstants._();
  
  //////////////////////////////////////////////////////////////////////////////
  // Display constants
  //////////////////////////////////////////////////////////////////////////////
  
  /// Mathematical axis height (the height of the mathematical axis above the baseline)
  /// This is used as a reference for positioning many elements in math formulas
  static double axisHeight(double fontSize) => fontSize * 0.25;
  
  /// Extra white space to be added after each subscript and superscript
  static double scriptSpace(double fontSize) => fontSize * 0.05;
  
  /// White space to be left between math formulas to ensure proper line spacing
  static double mathLeading(double fontSize) => fontSize * 0.15;
  
  //////////////////////////////////////////////////////////////////////////////
  // Fraction constants
  //////////////////////////////////////////////////////////////////////////////
  
  /// Default rule thickness for fraction bars, overlines, etc.
  static double defaultRuleThickness(double fontSize) => fontSize * 0.045;
  
  /// Minimum gap between numerator and fraction rule
  static double fractionNumeratorGapMin(double fontSize) => fontSize * 0.1;
  
  /// Minimum gap between fraction rule and denominator
  static double fractionDenominatorGapMin(double fontSize) => fontSize * 0.1;
  
  /// Minimum gap between numerator and fraction rule in display style
  static double fractionNumeratorDisplayStyleGapMin(double fontSize) => fontSize * 0.15;
  
  /// Minimum gap between fraction rule and denominator in display style
  static double fractionDenominatorDisplayStyleGapMin(double fontSize) => fontSize * 0.15;
  
  /// Minimum tolerated size for the fraction bar
  static double fractionRuleThickness(double fontSize) => defaultRuleThickness(fontSize);
  
  /// Distance between the baseline of the numerator and the equation axis
  static double fractionNumeratorShiftUp(double fontSize) => fontSize * 0.4;
  
  /// Distance between the baseline of the numerator and the equation axis in display style
  static double fractionNumeratorDisplayStyleShiftUp(double fontSize) => fontSize * 0.6;
  
  /// Distance between the baseline of the denominator and the equation axis
  static double fractionDenominatorShiftDown(double fontSize) => fontSize * 0.4;
  
  /// Distance between the baseline of the denominator and the equation axis in display style
  static double fractionDenominatorDisplayStyleShiftDown(double fontSize) => fontSize * 0.6;
  
  /// Minimum height of fraction bar from the baseline
  static double fractionBarHeight(double fontSize) => defaultRuleThickness(fontSize);

  //////////////////////////////////////////////////////////////////////////////
  // Script constants (sub/superscripts)
  //////////////////////////////////////////////////////////////////////////////
  
  /// Scale factor for first level of script elements (superscript, subscript)
  static double scriptScaleFactor = 0.7; // 70% of base size
  
  /// Scale factor for second level of script elements (superscript on superscript)
  static double scriptScriptScaleFactor = 0.5; // 50% of base size
  
  //////////////////////////////////////////////////////////////////////////////
  // Superscript constants
  //////////////////////////////////////////////////////////////////////////////
  
  /// Minimum distance between baseline of superscript and top of base glyph
  static double superscriptShiftUp(double fontSize) => fontSize * 0.35;
  
  /// Minimum distance between baseline of superscript and top of base in cramped mode
  static double superscriptShiftUpCramped(double fontSize) => fontSize * 0.25;
  
  /// Maximum allowed drop of the baseline of the superscript below the baseline of the base
  static double superscriptBaselineDropMax(double fontSize) => fontSize * 0.075;
  
  /// Minimum gap between the subscript and superscript
  static double subSuperscriptGapMin(double fontSize) => fontSize * 0.15;
  
  /// Maximum allowed height for the gap between the superscript and the base
  static double superscriptBottomMin(double fontSize) => fontSize * 0.1;
  
  /// Extra space to add to the top of a superscript
  static double superscriptBottomMaxWithSubscript(double fontSize) => fontSize * 0.2;
  
  //////////////////////////////////////////////////////////////////////////////
  // Subscript constants
  //////////////////////////////////////////////////////////////////////////////
  
  /// Minimum distance between baseline of subscript and bottom of the base glyph  
  static double subscriptShiftDown(double fontSize) => fontSize * 0.2;
  
  /// Minimum distance between baseline of subscript and baseline of the base
  static double subscriptBaselineDropMin(double fontSize) => fontSize * 0.075;
  
  /// Minimum distance between top of subscript and bottom of base
  static double subscriptTopMax(double fontSize) => fontSize * 0.3;
  
  //////////////////////////////////////////////////////////////////////////////
  // Limits spacing for large operators (like \sum, \prod, etc.)
  //////////////////////////////////////////////////////////////////////////////
  
  /// Minimum gap between the bottom of the upper limit, and the top of the base operator
  static double upperLimitGapMin(double fontSize) => fontSize * 0.1;
  
  /// Minimum distance between the bottom of the upper limit and the base operator top
  static double upperLimitBaselineRiseMin(double fontSize) => fontSize * 0.3;
  
  /// Minimum gap between the top of the lower limit, and the bottom of the base operator
  static double lowerLimitGapMin(double fontSize) => fontSize * 0.1;
  
  /// Minimum distance between the top of the lower limit and the base operator bottom
  static double lowerLimitBaselineDropMin(double fontSize) => fontSize * 0.4;
  
  /// Minimum height for treating a large operator in display mode
  static double displayOperatorMinHeight(double fontSize) => fontSize * 1.5;
  
  //////////////////////////////////////////////////////////////////////////////
  // Square root constants
  //////////////////////////////////////////////////////////////////////////////
  
  /// Thickness of the radical rule (square root symbol)
  static double radicalRuleThickness(double fontSize) => defaultRuleThickness(fontSize) * 1.1;
  
  /// Extra vertical space above the vinculum (horizontal line) of the radical
  static double radicalExtraAscender(double fontSize) => fontSize * 0.075;
  
  /// Vertical gap between the radical rule and the expression in non-display mode
  static double radicalVerticalGap(double fontSize) => fontSize * 0.05;
  
  /// Vertical gap between the radical rule and the expression in display mode
  static double radicalDisplayStyleVerticalGap(double fontSize) => fontSize * 0.1;
  
  /// Height of the radical degree, as proportion of the radical symbol height
  static double radicalDegreeBottomRaisePercent(double fontSize) => fontSize * 0.6;
  
  //////////////////////////////////////////////////////////////////////////////
  // Overbar and underbar constants
  //////////////////////////////////////////////////////////////////////////////
  
  /// Space between overbar and the expression
  static double overbarVerticalGap(double fontSize) => fontSize * 0.15;
  
  /// Thickness of overbar rule
  static double overbarRuleThickness(double fontSize) => defaultRuleThickness(fontSize);
  
  /// Extra white space reserved above the overbar
  static double overbarExtraAscender(double fontSize) => fontSize * 0.075;
  
  /// Space between underbar and the expression
  static double underbarVerticalGap(double fontSize) => fontSize * 0.15;
  
  /// Thickness of underbar rule
  static double underbarRuleThickness(double fontSize) => defaultRuleThickness(fontSize);
  
  /// Extra white space reserved below the underbar
  static double underbarExtraDescender(double fontSize) => fontSize * 0.075;
  
  //////////////////////////////////////////////////////////////////////////////
  // Delimiters (parentheses, brackets, etc.)
  //////////////////////////////////////////////////////////////////////////////
  
  /// Minimum size of a delimiter in formula
  static double delimiterDisplaySize(double fontSize) => fontSize * 1.8;
  
  /// Minimum size of a delimiter in standard mode
  static double delimiterSize(double fontSize) => fontSize * 1.2;
  
  /// Minimum overlap of connecting glyphs during glyph construction
  static double minConnectorOverlap(double fontSize) => fontSize * 0.1;
  
  //////////////////////////////////////////////////////////////////////////////
  // Matrix constants
  //////////////////////////////////////////////////////////////////////////////
  
  /// Spacing between rows in a matrix
  static double matrixRowSpacing(double fontSize) => fontSize * 0.15;
  
  /// Spacing between columns in a matrix
  static double matrixColumnSpacing(double fontSize) => fontSize * 0.5;
  
  //////////////////////////////////////////////////////////////////////////////
  // Helper methods
  //////////////////////////////////////////////////////////////////////////////
  
  /// Helper to determine if we should use display style based on size and mode
  /// This helps maintain consistent behavior throughout the code
  static bool isDisplayStyle(double fontSize, bool mathNodeDisplayMode) {
    // Use display style if explicitly set through MathNode or if fontSize is large enough
    return fontSize >= 14.0 || mathNodeDisplayMode;
  }
}
