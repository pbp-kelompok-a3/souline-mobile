import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const SoulineApp());
}

class SoulineApp extends StatelessWidget {
  const SoulineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Souline',
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFF7DD)),
        useMaterial3: true,
      ),
    );
  }
}
