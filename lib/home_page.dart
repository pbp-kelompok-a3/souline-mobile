import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:souline_mobile/modules/timeline/timeline_service.dart';

import './core/constants/app_constants.dart';
import './shared/widgets/left_drawer.dart';
import './shared/widgets/navigation_bar.dart';
import './shared/widgets/home_header.dart';
import './shared/widgets/cards/home_studio_card.dart';
import './shared/widgets/cards/home_event_card.dart';
import './shared/widgets/cards/home_resource_card.dart';
import './shared/widgets/cards/home_sportswear_card.dart';
import './shared/widgets/cards/home_timeline_card.dart';

import './shared/models/studio_entry.dart';
import './shared/models/resources_entry.dart';
import './shared/models/post_entry.dart';
import './shared/models/sportswear_model.dart';
import './shared/models/event_model.dart';

import 'modules/studio/studio_page.dart';
import 'modules/studio/studio_service.dart';
import 'modules/studio/studio_detail_page.dart';
import 'modules/sportswear/sportswear_page.dart';
import 'modules/sportswear/sportswear_service.dart';
import 'modules/resources/resources_page.dart';

import 'modules/timeline/timeline_page.dart';
import 'modules/timeline/timeline_service.dart';
import 'modules/timeline/post_detail.dart';
import 'modules/events/events_page.dart';
import 'modules/events/events_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Studio section state
  UserKota? _selectedCity;
  List<Studio> _studios = [];
  bool _isLoadingStudios = true;

  // Events section state
  String _eventFilter = 'all'; // 'all', 'soon', or 'later'
  List<EventModel> _events = [];
  bool _isLoadingEvents = true;

  // Resources section state
  String? _resourceFilter; // null = all, 'beginner', 'intermediate', 'advanced'
  List<ResourcesEntry> _resources = [];

  // Sportswear section state
  List<Product> _sportswear = [];
  bool _isLoadingSportswear = true;

  // Timeline section state
  List<Result> _timelinePosts = [];
  bool _isLoadingTimeline = true;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _loadStudios();
    _loadEvents();
    _loadSportswear();
    _loadTimeline();
  }

  /// Load studios from API
  Future<void> _loadStudios() async {
    setState(() => _isLoadingStudios = true);

    try {
      final request = context.read<CookieRequest>();
      final service = StudioService(request);
      final entry = await service.fetchStudios();

      if (!mounted) return;

      final userCity = entry.userKota;
      final effectiveCity = _selectedCity ?? userCity;

      final studios = <Studio>[];
      for (final city in entry.cities) {
        if (city.name == effectiveCity) {
          studios.addAll(city.studios.take(10));
          break;
        }
      }

      setState(() {
        _selectedCity = effectiveCity;
        _studios = studios;
        _isLoadingStudios = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingStudios = false);
      debugPrint('Error loading studios: $e');
    }
  }

  /// Load sportswear from API
    Future<void> _loadSportswear() async {
      if (!mounted) return;
      setState(() => _isLoadingSportswear = true);
      try {
        final request = context.read<CookieRequest>();
        final service = SportswearService(request);
        final products = await service.fetchBrands();

        if (!mounted) return;

        setState(() {
          _sportswear = products.take(10).toList();
          _isLoadingSportswear = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoadingSportswear = false);
        debugPrint('Error loading sportswear: $e');
      }
    }

  /// Load timeline posts from API (HANYA ADA SATU DI SINI)
  Future<void> _loadTimeline() async {
    setState(() => _isLoadingTimeline = true);
    try {
      final request = context.read<CookieRequest>();
      final service = TimelineService(request);
      final entry = await service.fetchPosts();

      if (!mounted) return;

      setState(() {
        // Sort by latest (descending ID) and take top 3
        final sorted = List<Result>.from(entry.results);
        sorted.sort((a, b) => b.id.compareTo(a.id));
        _timelinePosts = sorted.take(3).toList();
        _isLoadingTimeline = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingTimeline = false);
      debugPrint('Error loading timeline: $e');
    }
  }

  /// Join base URL with path
  String _joinBaseUrl(String path) {
    final base = AppConstants.baseUrl;
    if (base.endsWith('/')) return '$base$path';
    return '$base/$path';
  }

  /// Build full poster URL for events
  String _buildPosterUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return _joinBaseUrl(path);
  }

  /// Load events from API
  Future<void> _loadEvents() async {
    setState(() => _isLoadingEvents = true);

    try {
      String endpoint = 'events/json/';
      if (_eventFilter == 'soon') {
        endpoint = 'events/json/soon/';
      } else if (_eventFilter == 'later') {
        endpoint = 'events/json/later/';
      }

      final url = _joinBaseUrl(endpoint);
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(
          () => _events = data.map((e) => EventModel.fromJson(e)).toList(),
        );
        _isLoadingEvents = false;
      } else {
        throw Exception('Failed to load events (${response.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingEvents = false);
      debugPrint('Error loading events: $e');
    }
  }

  /// Load mock data for sections without API implementation
  void _loadMockData() {
    _resources = [
      ResourcesEntry(
        id: 1,
        title: '30 MIN PILATES',
        description:
            'This beginner-to-moderate level Pilates class is perfect...',
        youtubeUrl: 'https://www.youtube.com/embed/wtVyZmHnlxM',
        videoId: 'wtVyZmHnlxM',
        thumbnailUrl: 'https://img.youtube.com/vi/wtVyZmHnlxM/hqdefault.jpg',
        level: 'beginner',
      ),
      ResourcesEntry(
        id: 2,
        title: '30 MIN FULL BODY',
        description: 'Intermediate full body pilates...',
        youtubeUrl: 'https://www.youtube.com/embed/C2HX2pNbUCM',
        videoId: 'C2HX2pNbUCM',
        thumbnailUrl: 'https://img.youtube.com/vi/C2HX2pNbUCM/hqdefault.jpg',
        level: 'intermediate',
      ),
    ];
  }

  List<ResourcesEntry> get _filteredResources {
    if (_resourceFilter == null) return _resources;
    return _resources
        .where((r) => r.level.toLowerCase() == _resourceFilter)
        .toList();
  }

  List<EventModel> get _filteredEvents => _events;

  void _onCityChanged(UserKota? city) {
    if (city != null) {
      setState(() => _selectedCity = city);
      _loadStudios();
    }
  }

  void _onEventFilterChanged(String? filter) {
    if (filter != null && filter != _eventFilter) {
      setState(() => _eventFilter = filter);
      _loadEvents();
    }
  }

  void _onResourceFilterChanged(String? level) {
    setState(() => _resourceFilter = level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      drawer: const LeftDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 26),
                      _buildSectionHeader(
                        title: 'Studio',
                        dropdownValue: _selectedCity,
                        dropdownItems: UserKota.values
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(userKotaValues.reverse[city] ?? ''),
                              ),
                            )
                            .toList(),
                        onDropdownChanged: _onCityChanged,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StudioPage()),
                        ),
                      ),
                      _buildStudioSection(),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        title: 'Event',
                        dropdownValue: _eventFilter,
                        dropdownItems: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(value: 'soon', child: Text('This Week')),
                          DropdownMenuItem(value: 'later', child: Text('Later')),
                        ],
                        onDropdownChanged: _onEventFilterChanged,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EventsPage()),
                        ),
                      ),
                      _buildEventsSection(),
                      const SizedBox(height: 24),
                      _buildSectionHeader<String?>(
                        title: 'Resources',
                        dropdownValue: _resourceFilter,
                        dropdownItems: const [
                          DropdownMenuItem<String?>(value: null, child: Text('All')),
                          DropdownMenuItem<String?>(value: 'beginner', child: Text('Beginner')),
                          DropdownMenuItem<String?>(value: 'intermediate', child: Text('Intermediate')),
                          DropdownMenuItem<String?>(value: 'advanced', child: Text('Advanced')),
                        ],
                        onDropdownChanged: _onResourceFilterChanged,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ResourcesPage()),
                        ),
                      ),
                      _buildResourcesSection(),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        title: 'Sportswear',
                        onSeeAll: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SportswearPage()),
                          );
                          if (result == true) _loadSportswear();
                        },
                      ),
                      _buildSportswearSection(),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        title: 'Timeline',
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TimelinePage()),
                        ),
                      ),
                      _buildTimelineSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingNavigationBar(currentIndex: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader<T>({
    required String title,
    T? dropdownValue,
    List<DropdownMenuItem<T>>? dropdownItems,
    ValueChanged<T?>? onDropdownChanged,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text('See All', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.orange)),
                ),
            ],
          ),
          if (dropdownItems != null && dropdownItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.lightBlue.withValues(alpha: 0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: dropdownValue,
                  items: dropdownItems,
                  onChanged: onDropdownChanged,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.darkBlue),
                  style: const TextStyle(fontSize: 14, color: AppColors.darkBlue, fontFamily: 'Poppins'),
                  isDense: true,
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStudioSection() {
    if (_isLoadingStudios) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.teal)));
    if (_studios.isEmpty) return SizedBox(height: 200, child: Center(child: Text('No studios found', style: TextStyle(color: AppColors.textMuted))));
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _studios.length,
        itemBuilder: (context, index) => HomeStudioCard(studio: _studios[index], onTap: () {}),
      ),
    );
  }

  Widget _buildEventsSection() {
    if (_isLoadingEvents) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.teal)));
    if (_events.isEmpty) return SizedBox(height: 200, child: Center(child: Text('No events found', style: TextStyle(color: AppColors.textMuted))));
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _events.length,
        itemBuilder: (context, index) => HomeEventCard(event: _events[index], posterUrl: _buildPosterUrl(_events[index].poster), onTap: () {}),
      ),
    );
  }

  Widget _buildResourcesSection() {
    final resources = _filteredResources;
    if (resources.isEmpty) return SizedBox(height: 280, child: Center(child: Text('No resources found', style: TextStyle(color: AppColors.textMuted))));
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: resources.length,
        itemBuilder: (context, index) => HomeResourceCard(resource: resources[index]),
      ),
    );
  }

  Widget _buildSportswearSection() {
    if (_isLoadingSportswear) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(color: AppColors.teal))
      );
    }

    if (_sportswear.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No sportswear available'))
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _sportswear.length,
        itemBuilder: (context, index) => HomeSportswearCard(product: _sportswear[index]),
      ),
    );
  }

  Widget _buildTimelineSection() {
    if (_isLoadingTimeline) return const Center(child: CircularProgressIndicator());
    if (_timelinePosts.isEmpty) return const Center(child: Text('No posts yet'));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _timelinePosts.map((post) => HomeTimelineCard(post: post, onTap: () {})).toList(),
      ),
    );
  }
}