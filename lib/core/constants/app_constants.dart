import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Souline';
  static const String appVersion = '1.0.0';

  // API URLs
  // static const String baseUrl = 'https://farrel-rifqi-souline.pbp.cs.ui.ac.id/';
  static const String baseUrl = 'http://localhost:8000/';

  // Shared preferences keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
}

/// App Color Palette
class AppColors {
  // Primary colors
  static const Color darkBlue = Color(0xFF446178);
  static const Color teal = Color(0xFF91C4C3);
  static const Color lightGreen = Color(0xFFB4DE8D);
  static const Color cream = Color(0xFFFFFBF0);
  static const Color orange = Color(0xFFFFA04D);
  static const Color lightBlue = Color(0xFF8BC4DA);

  // Semantic colors
  static const Color primary = darkBlue;
  static const Color secondary = teal;
  static const Color accent = orange;
  static const Color background = cream;
  static const Color success = lightGreen;

  // Text colors
  static const Color textDark = darkBlue;
  static const Color textLight = Colors.white;
  static const Color textMuted = Color(0xFF7A8D9C);
}
