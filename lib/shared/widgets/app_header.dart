import 'package:flutter/material.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final Function(String)? onSearchChanged; // <-- search logic beda tiap modul
  final VoidCallback? onFilterPressed; // <-- filter logic beda tiap modul

  const AppHeader({
    super.key,
    required this.title,
    this.onSearchChanged,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // HEADER GRADIENT
        Container(
          height: 160,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7EB3DE), Color(0xFF446178)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // ⬅️ aksi kembali
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 28),
            ],
          ),
        ),

        // SEARCH BAR
        Positioned(
          left: 24,
          right: 96,
          bottom: -28,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.lightBlue),
            ),
            child: TextField(
              onChanged: onSearchChanged, // <--- pake callback
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(Icons.search, size: 20, color: AppColors.textMuted),
                ),
                hintText: "Search...",
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),

        // FILTER BUTTON
        Positioned(
          right: 24,
          bottom: -24,
          child: GestureDetector(
            onTap: onFilterPressed, // <--- pake callback
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.tune, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
