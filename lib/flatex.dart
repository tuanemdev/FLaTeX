library;

import 'package:flatex/util/font_loader.dart';

// Export the configuration
export 'src/config/font_config.dart';

// Export all public components
export 'package:flatex/widgets/latex_widget.dart';
export 'package:flatex/model/node.dart';

// Initialize math fonts when library is imported
class FLaTeX {
  /// Initialize the LaTeX renderer and preload fonts from tuanemdev/LaTeX
  static Future<void> initialize() async {
    await MathFontLoader.preloadFonts();
  }
  
  /// Get the version of the LaTeX library
  static String get version => '1.0.0';
  
  /// Available math font families
  static List<String> get availableFonts => MathFontLoader.mathFonts;
}
