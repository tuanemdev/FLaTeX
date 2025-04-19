import 'package:flutter/services.dart';

/// Utility class to load and initialize math fonts
class MathFontLoader {
  // Private constructor to prevent instantiation
  MathFontLoader._();
  
  static bool _fontsLoaded = false;
  static final Map<String, bool> _loadedFonts = {};
  
  /// Available math font families from FLaTeX
  static const List<String> mathFonts = [
    'LatinModern', // First in the list
    'Xits',
    'Libertinus',
    'Asana',
    'Fira',
    'Garamond',
    'Texgyretermes',
    'Kp',         // Adding Kp fonts - found in many .plist files
    'Lete',       // Adding Lete fonts - found in .plist files
    'Euler',      // Adding Euler - found in .plist files
    'NotoSans',   // Adding NotoSans - found in .plist files
  ];
  
  /// Maps font family names to their respective file paths
  static const Map<String, String> _fontPaths = {
    'LatinModern': 'fonts/LatinModern/latinmodern-math.otf',
    'Xits': 'fonts/Xits/xits-math.otf',
    'Libertinus': 'fonts/Libertinus/libertinusmath-regular.otf',
    'Asana': 'fonts/Asana/Asana-Math.otf',
    'Fira': 'fonts/Fira/FiraMath-Regular.otf',
    'Garamond': 'fonts/Garamond/Garamond-Math.otf',
    'Texgyretermes': 'fonts/Texgyretermes/texgyretermes-math.otf',
    'Kp': 'fonts/Kp/KpMath-Light.otf',
    'Lete': 'fonts/Lete/LeteSansMath.otf',
    'Euler': 'fonts/Euler/Euler-Math.otf',
    'NotoSans': 'fonts/NotoSans/NotoSansMath-Regular.otf',
  };
  
  /// Default font for math display
  static const String defaultMathFont = 'LatinModern';
  
  /// Preload font assets for better performance
  static Future<bool> preloadFonts() async {
    if (_fontsLoaded) return true;
    
    try {
      // Load most common fonts first
      final futures = <Future<ByteData>>[];
      for (final font in mathFonts.take(5)) { // Load first 5 fonts
        futures.add(_loadFont(_fontPaths[font]!));
        _loadedFonts[font] = true;
      }
      
      await Future.wait(futures);
      _fontsLoaded = true;
      return true;
    } catch (e) {
      print('Warning: Could not preload math fonts: $e');
      return false;
    }
  }
  
  /// Load a specific font on demand
  static Future<bool> loadFont(String fontFamily) async {
    if (_loadedFonts[fontFamily] == true) return true;
    
    if (!_fontPaths.containsKey(fontFamily)) {
      return false;
    }
    
    try {
      await _loadFont(_fontPaths[fontFamily]!);
      _loadedFonts[fontFamily] = true;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if a specific font has been loaded
  static bool isFontLoaded(String fontFamily) {
    return _loadedFonts[fontFamily] == true;
  }
  
  // Helper to load a single font file
  static Future<ByteData> _loadFont(String? fontPath) {
    if (fontPath == null) {
      throw ArgumentError('Font path cannot be null');
    }
    return rootBundle.load(fontPath);
  }
}
