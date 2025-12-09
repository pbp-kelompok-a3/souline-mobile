import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/widgets/navigation_bar.dart';
import 'events_detail.dart';
import 'add_events.dart';
import 'widgets/events_card.dart';
import 'widgets/events_filter.dart';

class EventModel {
  final int id;
  final String name;
  final DateTime date;
  final String description;
  final String poster;

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.description,
    required this.poster,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      name: json['name'],
      date: DateFormat("dd MMMM yyyy").parse(json['date']),
      description: json['description'] ?? '',
      poster: json['poster'] ?? '',
    );
  }
}

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String selectedCity = 'Jakarta';
  String selectedDateFilter = 'all'; // all / soon / later
  late Future<List<EventModel>> futureEvents;

  bool isFilterVisible = false;

  bool isLoggedIn = true; // ganti sesuai auth kamu

  String joinBase(String path) {
    final base = AppConstants.baseUrl;
    if (base.endsWith('/')) return '$base$path';
    return '$base/$path';
  }

  String buildPosterUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return joinBase(path);
  }

  @override
  void initState() {
    super.initState();
    futureEvents = fetchEvents();
  }

  Future<List<EventModel>> fetchEvents() async {
    String url = joinBase('events/json/');
    if (selectedDateFilter == 'soon') {
      url = joinBase('events/json/soon/');
    } else if (selectedDateFilter == 'later') {
      url = joinBase('events/json/later/');
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => EventModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  void _toggleFilter() {
    setState(() {
      isFilterVisible = !isFilterVisible;
    });
  }

  void _applyFilter(String city, String dateFilter) {
    setState(() {
      selectedCity = city;
      selectedDateFilter = dateFilter;
      isFilterVisible = false;
      futureEvents = fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          Column(
            children: [
              // HEADER
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.darkBlue, AppColors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.bottomCenter,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    "Event",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // SEARCH + FILTER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Search events',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _toggleFilter,
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // CITY
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "📍 $selectedCity",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // LIST
              Expanded(
                child: FutureBuilder<List<EventModel>>(
                  future: futureEvents,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final events = snapshot.data!;

                    return ListView.builder(
                      padding:
                          const EdgeInsets.only(bottom: 120, left: 16, right: 16),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return EventCard(
                          event: event,
                          posterUrl: buildPosterUrl(event.poster),
                          onDetail: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailPage(
                                  event: event,
                                  baseUrl: AppConstants.baseUrl,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          if (isFilterVisible)
            EventFilter(onApply: _applyFilter),

          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavigationBar(currentIndex: 4),
          )
        ],
      ),

      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
              backgroundColor: AppColors.teal,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEventPage()),
                );
              },
            )
          : null,
    );
  }
}
