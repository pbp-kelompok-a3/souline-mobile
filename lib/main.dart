import 'package:flutter/material.dart';
import 'home_page.dart';
import 'modules/timeline/timeline_page.dart';
import 'modules/timeline/create_post.dart';
import 'modules/events/events_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const SoulineApp());
}

class SoulineApp extends StatelessWidget {
  const SoulineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Souline',
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFF7DD)),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        routes: {
          '/timeline': (context) => TimelinePage(),
          '/create_post': (context) => CreatePostPage(),
          '/events': (context) => const EventsPage(),
          // '/profile': (context) => ProfilePage(),
        },
      ),
    );
  }
}
