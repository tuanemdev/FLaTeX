import 'package:flutter/material.dart';
import 'package:flatex/flatex.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FLaTeX Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FLaTeX: Flutter LaTeX Renderer'),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: LaTeX(
                  r'E = mc^2',
                  fontSize: 24,
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: LaTeX(
                  r'\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}',
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: LaTeX(
                  r'\int_{a}^{b} f(x) \, dx = F(b) - F(a)',
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: LaTeX(
                  r'\sum_{i=1}^{n} i = \frac{n(n+1)}{2}',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
    );
  }
}
