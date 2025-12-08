import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.cream,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            const SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.darkBlue,
                    child: Icon(Icons.person, size: 40, color: AppColors.cream),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Username', // TODO: Replace with actual username getting logic
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Location', // TODO: Replace with actual location getting logic
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: AppColors.darkBlue.withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.person_outline,
                color: AppColors.darkBlue,
                size: 30,
              ),
              title: const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
              onTap: () {
                // TODO: Navigate to Profile Page
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.bookmark_border,
                color: AppColors.darkBlue,
                size: 30,
              ),
              title: const Text(
                'Bookmarks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
              onTap: () {
                // TODO: Navigate to Bookmarks Page
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
