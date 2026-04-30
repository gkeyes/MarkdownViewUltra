import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MarkdownViewApp());
}

class MarkdownViewApp extends StatelessWidget {
  const MarkdownViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown View',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}