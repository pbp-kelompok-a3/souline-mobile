import 'package:flutter/material.dart';

class LevelBadge extends StatelessWidget {
  final String level;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;

  const LevelBadge({
    super.key,
    required this.level,
    this.fontSize = 12,
    this.horizontalPadding = 10,
    this.verticalPadding = 4,
  });

  Color _backgroundColor() {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF84D000); // hijau
      case 'intermediate':
        return const Color(0xFF8BC5FF); // biru
      case 'advanced':
        return const Color(0xFFD191EF); // ungu
      default:
        return const Color(0xFF7A7C89); // abu fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        level[0].toUpperCase() + level.substring(1),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
