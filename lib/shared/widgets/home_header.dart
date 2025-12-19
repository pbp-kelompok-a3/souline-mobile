import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final Function(String)? onSearchChanged;

  const HomeHeader({super.key, this.onMenuPressed, this.onSearchChanged});

  // Header gradient height
  static const double _headerHeight = 160;
  // Search bar overflow below header
  static const double _searchBarOverflow = 25;
  // Total height including overflow
  static const double totalHeight = _headerHeight + _searchBarOverflow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // HEADER GRADIENT
          Container(
            height: _headerHeight,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7EB3DE), Color(0xFF446178)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hamburger menu with click feedback
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          onMenuPressed ??
                          () {
                            Scaffold.of(context).openDrawer();
                          },
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.menu, color: Colors.white, size: 28),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Logo aligned to the right
                  Image.asset(
                    'assets/image/logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'SOULINE',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // SEARCH BAR
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.lightBlue),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ),
                  hintText: "Search studios, events, and more",
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
