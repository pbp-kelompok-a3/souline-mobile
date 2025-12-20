import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/left_drawer.dart';
import '../../shared/widgets/navigation_bar.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/models/event_model.dart';
import 'events_detail.dart';
import 'add_events.dart';
import 'widgets/events_card.dart';
import 'widgets/events_filter.dart';
import 'events_service.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String selectedCity = '';
  String selectedDateFilter = 'all';
  late Future<List<EventModel>> futureEvents;
  bool isFilterVisible = false;
  String currentUsername = '';
  String authToken = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAuthInfo().then((_) {
      futureEvents = fetchEvents();
      setState(() {});
    });
  }

  Future<void> _loadAuthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    currentUsername = prefs.getString('username') ?? '';
    authToken = prefs.getString('auth_token') ?? '';
  }

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

  Future<List<EventModel>> fetchEvents() async {
    final url = joinBase('events/json/');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authToken.isNotEmpty) headers['Authorization'] = 'Token $authToken';

    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => EventModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events (${response.statusCode})');
    }
  }

  Future<void> _deleteEvent(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    final url = joinBase('events/api/$id/delete/');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authToken.isNotEmpty) headers['Authorization'] = 'Token $authToken';

    final resp = await http.delete(Uri.parse(url), headers: headers);
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted')));
      setState(() {
        futureEvents = fetchEvents();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${resp.statusCode}')),
      );
    }
  }

  void _toggleFilter() {
    setState(() => isFilterVisible = !isFilterVisible);
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
    final headerLocationLabel = selectedCity.isEmpty ? 'All Locations' : selectedCity;

    return Scaffold(
      backgroundColor: AppColors.cream,
      drawer: const LeftDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(
                title: 'Events',
                onSearchChanged: (value) => setState(() => _searchQuery = value),
                onFilterPressed: _toggleFilter,
                showDrawerButton: true,
              ),
              const SizedBox(height: 40),
              // location label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Text('📍 ', style: TextStyle(fontSize: 20)),
                      Text(
                        headerLocationLabel,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (selectedCity.isNotEmpty)
                        TextButton(
                          onPressed: () => _applyFilter('', 'all'),
                          child: const Text('Clear', style: TextStyle(color: AppColors.darkBlue)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // list area
              Expanded(
                child: FutureBuilder<List<EventModel>>(
                  future: futureEvents,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final allEvents = snapshot.data ?? [];
                    final visibleEvents = allEvents.where((e) {
                      final matchesCity = selectedCity.isEmpty || e.location.toLowerCase().contains(selectedCity.toLowerCase());
                      final matchesSearch = _searchQuery.isEmpty || e.name.toLowerCase().contains(_searchQuery.toLowerCase()) || e.location.toLowerCase().contains(_searchQuery.toLowerCase());
                      return matchesCity && matchesSearch;
                    }).toList();

                    if (visibleEvents.isEmpty) {
                      return const Center(child: Text('No upcoming events yet.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 120, left: 16, right: 16, top: 8),
                      itemCount: visibleEvents.length,
                      itemBuilder: (context, index) {
                        final event = visibleEvents[index];
                        final isOwner = currentUsername.isNotEmpty && currentUsername == event.createdBy;
                        return EventCard(
                          event: event,
                          posterUrl: buildPosterUrl(event.poster),
                          isOwner: isOwner,
                          onDetail: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailPage(
                                  event: event,
                                  baseUrl: AppConstants.baseUrl,
                                  currentUsername: currentUsername,
                                ),
                              ),
                            ).then((_) => setState(() => futureEvents = fetchEvents()));
                          },
                          onEdit: isOwner
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => AddEventPage(editEvent: event)),
                                  ).then((_) => setState(() => futureEvents = fetchEvents()));
                                }
                              : null,
                          onDelete: isOwner ? () => _deleteEvent(event.id) : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (isFilterVisible)
            Positioned(
              top: 180,
              left: 20,
              right: 20,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(16),
                child: EventFilter(onApply: _applyFilter),
              ),
            ),
          const Positioned(left: 0, right: 0, bottom: 0, child: FloatingNavigationBar(currentIndex: 3)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: AppColors.orange,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEventPage()),
            ).then((_) => setState(() => futureEvents = fetchEvents()));
          },
        ),
      ),
    );
  }
}
