import 'package:flutter/material.dart';
import 'home_page.dart';
import 'modules/timeline/timeline_page.dart';
import 'modules/timeline/create_post.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFFBF0)),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      routes: {
        '/timeline': (context) => TimelinePage(),
        '/create_post': (context) => CreatePostPage(),
        // '/profile': (context) => ProfilePage(),
      },
    );
  }
}
