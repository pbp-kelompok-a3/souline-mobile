import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../home_page.dart';
import '../../modules/events/events_page.dart';
import '../../modules/sportswear/sportswear_page.dart';
import '../../modules/studio/studio_page.dart';
import '../../modules/timeline/timeline_page.dart';

class FloatingNavigationBar extends StatelessWidget {
  final int currentIndex;

  const FloatingNavigationBar({
    super.key,
    this.currentIndex = 2, // Home page
  });

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [
      Icons.grid_view_outlined,
      Icons.location_on_outlined,
      Icons.home_outlined,
      Icons.calendar_today_outlined,
      Icons.people_alt_outlined,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(icons.length, (index) {
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => _onItemTapped(context, index),
            child: Container(
              padding: const EdgeInsets.all(3),
              child: Icon(
                icons[index],
                color: isSelected ? AppColors.darkBlue : Colors.grey,
                size: 28,
              ),
            ),
          );
        }),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const SportswearPage();
        break;
      case 1:
        page = const StudioPage();
        break;
      case 2:
        page = const HomePage();
        break;
      case 3:
        page = const EventsPage();
        break;
      case 4:
        page = const TimelinePage();
        break;
      default:
        return;
    }

    if (index == 2) {
      // Remove all previous routes and navigate to Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => page),
        (route) => false,
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }
  }
}
