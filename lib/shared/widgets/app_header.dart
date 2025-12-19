import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final Function(String)? onSearchChanged;
  final VoidCallback? onFilterPressed;
  final String? filterHeroTag;
  final Widget? filterButton;
  final bool showDrawerButton; // <-- tampilkan left drawer

  const AppHeader({
    super.key,
    required this.title,
    this.onSearchChanged,
    this.onFilterPressed,
    this.filterHeroTag,
    this.filterButton,
    this.showDrawerButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // Build filter button with Material + InkWell for proper click feedback
    Widget filterBtn =
        filterButton ??
        Material(
          color: const Color(0xFF62C4D9),
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onFilterPressed,
            borderRadius: BorderRadius.circular(18),
            child: const SizedBox(
              height: 48,
              width: 48,
              child: Icon(Icons.tune, color: Colors.white),
            ),
          ),
        );

    if (filterHeroTag != null && filterButton == null) {
      filterBtn = Hero(tag: filterHeroTag!, child: filterBtn);
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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (showDrawerButton) {
                      Scaffold.of(context).openDrawer();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      showDrawerButton ? Icons.menu : Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
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
            ],
          ),
        ),

        // SEARCH BAR
        Positioned(
          left: 24,
          right: 88,
          bottom: -25,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF62C4D9)),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search...",
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        // FILTER BUTTON
        Positioned(
          right: 24,
          bottom: -25,
          child: SizedBox(
            height: 50,
            width: 50,
            child: Center(child: filterBtn),
          ),
        ),
      ],
    );
  }
}
