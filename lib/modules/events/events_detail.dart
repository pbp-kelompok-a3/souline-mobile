import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import 'events_page.dart';

class EventDetailPage extends StatelessWidget {
  final EventModel event;
  final String baseUrl;

  const EventDetailPage({
    super.key,
    required this.event,
    required this.baseUrl,
  });

  String buildPosterUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Event Detail'),
        backgroundColor: AppColors.cream,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.poster.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  buildPosterUrl(event.poster),
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              event.name,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(DateFormat("dd MMMM yyyy").format(event.date)),
            const SizedBox(height: 20),
            const Text("Description",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(event.description),
          ],
        ),
      ),
    );
  }
}
