import 'package:flutter/material.dart';

/// Configuration class for FLaTeX font settings
class FLaTeXFontConfig {
  /// The default font family to use for rendering LaTeX equations
  static const String defaultFontFamily = 'LatinModern';
  
  /// Available math fonts in the package
  static const List<String> availableFonts = [
    'LatinModern', // default
    'Xits',
    'Libertinus',
    'Asana',
    'Fira',
    'Garamond',
    'Texgyretermes',
  ];
  
  /// Get text style with the default math font
  static TextStyle get defaultMathTextStyle => TextStyle(
    fontFamily: defaultFontFamily,
    // You can add more default styling properties here
  );
  
  /// Create a text style with a specific math font
  static TextStyle withFont(String fontFamily) => TextStyle(
    fontFamily: availableFonts.contains(fontFamily) ? fontFamily : defaultFontFamily,
  );
}
