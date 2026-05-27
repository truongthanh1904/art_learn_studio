import 'package:flutter/material.dart';

import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const ArtLearnPersonalApp());
}

/// Ứng dụng frontend cho module bài hướng dẫn nghệ thuật và Art Studio.
class ArtLearnPersonalApp extends StatelessWidget {
  const ArtLearnPersonalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Art Learn Personal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const MainNavigationScreen(),
    );
  }
}