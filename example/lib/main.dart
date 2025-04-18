import 'package:flutter/material.dart';
import 'package:flatex/widgets/latex_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('LaTeX Renderer')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LatexWidget(
                  latexCode: r'\sigma = \sqrt{\frac{1}{N}\sum_{i=1}^N (x_i - \mu)^2}',
                  scale: 1.8, // Increase scale for better visibility
                ),
                const SizedBox(height: 32),
                // Match the equation from the image
                const LatexWidget(
                  latexCode: r'\sum_{n=1}^\infty \frac{1}{n^2} = \frac{\pi}{6}',
                  scale: 1.8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
