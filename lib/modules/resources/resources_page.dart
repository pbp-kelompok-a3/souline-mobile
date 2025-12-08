import 'package:flutter/material.dart';
import 'package:souline_mobile/shared/widgets/app_header.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: Column(
          children: [
              AppHeader(title: "Resources"),
            
          ],
        ),
      ),
    );
  }
}