# LaTeX Renderer for Flutter

A lightweight, pure Dart package for rendering LaTeX expressions in your Flutter applications without any JavaScript dependencies.

## Features

- Pure Dart implementation - no WebView or JavaScript required
- Fast rendering with efficient caching
- Support for common LaTeX mathematical notations
- Customizable styling options
- Flutter-native widget

## Installation

Add this package to your pubspec.yaml:
```yaml
dependencies:
  flatex: ^1.0.0
```

Then run:
```bash
flutter pub get
```

## Usage

Using the LaTeX renderer is as simple as:
```dart
import 'package:flatex/flatex.dart';
```

In your widget tree
```dart
LaTeX(r'E = mc^2')
```

With custom styling
```dart
LaTeX(
  r'\int_{a}^{b} f(x) \, dx = F(b) - F(a)',
  textColor: Colors.blue,
  fontSize: 18.0,
)
```

You can customize the appearance of LaTeX expressions:
```dart
LaTeX(
  r'\sum_{i=1}^{n} i = \frac{n(n+1)}{2}',
  textColor: Colors.black,
  backgroundColor: Colors.white,
  fontSize: 16.0,
  fontWeight: FontWeight.normal,
  alignment: Alignment.center,
)
```

## License
GNU v3.0
