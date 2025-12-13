import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final Function(String)? onSearchChanged; // <-- search logic beda tiap modul
  final VoidCallback? onFilterPressed;     // <-- filter logic beda tiap modul
  final String? filterHeroTag;             // <-- hero tag OPSIONAL

  const AppHeader({
    super.key,
    required this.title,
    this.onSearchChanged,
    this.onFilterPressed,
    this.filterHeroTag,
  });

  @override
  Widget build(BuildContext context) {

    Widget filterButton = GestureDetector(
      onTap: onFilterPressed, // <--- pake callback
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF62C4D9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.tune, color: Colors.white),
      ),
    );


    if (filterHeroTag != null) {
      filterButton = Hero(
        tag: filterHeroTag!,
        child: filterButton,
      );
    }

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
                  Navigator.pop(context); 
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              Expanded(
                child: Center(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
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
              border: Border.all(color: const Color(0xFF62C4D9)),
            ),
            child: TextField(
              onChanged: onSearchChanged, // <--- pake callback
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search...",
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        // FILTER BUTTON (pakai filterButton yang sudah bisa Hero)
        Positioned(
          right: 24,
          bottom: -24,
          child: filterButton,
        ),
      ],
    );
  }
}
