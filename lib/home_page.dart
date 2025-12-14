import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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

import 'modules/studio/studio_page.dart';
import 'modules/studio/studio_service.dart';
import 'modules/studio/studio_detail_page.dart';
import 'modules/sportswear/sportswear_page.dart';
import 'modules/resources/resources_page.dart';
import 'modules/timeline/timeline_page.dart';
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
  UserKota? _selectedCity; // null until loaded from API
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

  // Timeline section state
  List<Result> _timelinePosts = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _loadStudios();
    _loadEvents();
  }

  /// Load studios from API
  Future<void> _loadStudios() async {
    setState(() => _isLoadingStudios = true);

    try {
      final request = context.read<CookieRequest>();
      final service = StudioService(request);
      final entry = await service.fetchStudios();

      if (!mounted) return;

      // Set selected city from API if not already set
      final userCity = entry.userKota;
      final effectiveCity = _selectedCity ?? userCity;

      // Get studios for selected city (limit to 10)
      final studios = <Studio>[];
      for (final city in entry.cities) {
        if (city.name == effectiveCity) {
          studios.addAll(city.studios.take(10));
          break;
        }
      }

      // If no studios for selected city, try user's city
      if (studios.isEmpty) {
        for (final city in entry.cities) {
          if (city.name == entry.userKota) {
            studios.addAll(city.studios.take(10));
            break;
          }
        }
      }

      setState(() {
        _selectedCity = effectiveCity; // Set from API response
        _studios = studios;
        _isLoadingStudios = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingStudios = false);
      debugPrint('Error loading studios: $e');
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
      // Determine endpoint based on filter
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
        setState(() {
          _events = data.map((e) => EventModel.fromJson(e)).toList();
          _isLoadingEvents = false;
        });
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
    // Mock resources data
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
      ResourcesEntry(
        id: 3,
        title: 'LATIHAN PILATES SELURUH TUBUH 20 MENIT',
        description: 'Beginner pilates session...',
        youtubeUrl: 'https://www.youtube.com/embed/sPNpgaXVGw4',
        videoId: 'sPNpgaXVGw4',
        thumbnailUrl: 'https://img.youtube.com/vi/sPNpgaXVGw4/hqdefault.jpg',
        level: 'beginner',
      ),
      ResourcesEntry(
        id: 4,
        title: 'ADVANCED PILATES WORKOUT',
        description: 'Advanced pilates session...',
        youtubeUrl: 'https://www.youtube.com/embed/sPNpgaXVGw4',
        videoId: 'sPNpgaXVGw4',
        thumbnailUrl: 'https://img.youtube.com/vi/sPNpgaXVGw4/hqdefault.jpg',
        level: 'advanced',
      ),
    ];

    // Mock sportswear data
    _sportswear = [
      Product(
        id: 1,
        name: 'Anmo Yoga',
        description: 'Premium yoga apparel brand',
        tag: 'Yoga',
        thumbnail:
            'https://down-id.img.susercontent.com/file/id-11134207-7r992-lw5v3iuwq2eu75',
        rating: 4.5,
        link: 'https://shopee.co.id/anmoyoga',
        timelineReviews: [],
      ),
      Product(
        id: 2,
        name: 'COSI Active',
        description: 'Activewear for your lifestyle',
        tag: 'Pilates',
        thumbnail:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT55LRzTCQi9Dw4H3P9DQHYF2Ax0OTv7xN1Sw&s',
        rating: 4.3,
        link: 'https://www.tokopedia.com/cosiactive',
        timelineReviews: [],
      ),
      Product(
        id: 3,
        name: 'HAPPYFIT',
        description: 'Fitness equipment & accessories',
        tag: 'Yoga',
        thumbnail:
            'https://images.tokopedia.net/img/cache/500-square/VqbcmM/2022/11/13/3db3a7d1-c7f0-4e9c-88f1-83e56e9cf597.jpg',
        rating: 4.7,
        link: 'https://www.tokopedia.com/happyfit',
        timelineReviews: [],
      ),
      Product(
        id: 4,
        name: 'Aura Apparel',
        description: 'Sustainable activewear',
        tag: 'Yoga',
        thumbnail:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSGH7TbCPEbhmQkQbE3_oS6N3h5nAU8FvQ3aw&s',
        rating: 4.4,
        link: 'https://shopee.co.id/auraapparel',
        timelineReviews: [],
      ),
    ];

    // Mock timeline posts
    _timelinePosts = [
      Result(
        id: 1,
        authorUsername: 'yogalover',
        text:
            'Just finished my morning yoga session! Feeling refreshed and ready to start the day 🧘‍♀️',
        likeCount: 24,
        commentCount: 5,
        likedByUser: false,
        comments: [],
        created_at: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Result(
        id: 2,
        authorUsername: 'pilatesqueen',
        text:
            'Anyone tried the new pilates studio in Kemang? The instructors are amazing!',
        likeCount: 18,
        commentCount: 12,
        likedByUser: true,
        comments: [],
        created_at: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Result(
        id: 3,
        authorUsername: 'fitnessjunkie',
        text: 'Week 4 of my yoga challenge complete! The progress is real 💪',
        likeCount: 45,
        commentCount: 8,
        likedByUser: false,
        comments: [],
        created_at: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Filter resources by level
  List<ResourcesEntry> get _filteredResources {
    if (_resourceFilter == null) return _resources;
    return _resources
        .where((r) => r.level.toLowerCase() == _resourceFilter)
        .toList();
  }

  /// Get filtered events
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
      _loadEvents(); // Reload with new filter
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
          // Column layout with sticky header
          Column(
            children: [
              // Sticky Header with logo and search
              const HomeHeader(),

              // Scrollable content below header
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 26),

                      // Studio Section
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

                      // Events Section
                      _buildSectionHeader(
                        title: 'Event',
                        dropdownValue: _eventFilter,
                        dropdownItems: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(
                            value: 'soon',
                            child: Text('This Week'),
                          ),
                          DropdownMenuItem(
                            value: 'later',
                            child: Text('Later'),
                          ),
                        ],
                        onDropdownChanged: _onEventFilterChanged,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EventsPage()),
                        ),
                      ),
                      _buildEventsSection(),

                      const SizedBox(height: 24),

                      // Resources Section
                      _buildSectionHeader<String?>(
                        title: 'Resources',
                        dropdownValue: _resourceFilter,
                        dropdownItems: const [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'beginner',
                            child: Text('Beginner'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'intermediate',
                            child: Text('Intermediate'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'advanced',
                            child: Text('Advanced'),
                          ),
                        ],
                        onDropdownChanged: _onResourceFilterChanged,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ResourcesPage(),
                          ),
                        ),
                      ),
                      _buildResourcesSection(),

                      const SizedBox(height: 24),

                      // Sportswear Section
                      _buildSectionHeader(
                        title: 'Sportswear',
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SportswearPage(),
                          ),
                        ),
                      ),
                      _buildSportswearSection(),

                      const SizedBox(height: 24),

                      // Timeline Section
                      _buildSectionHeader(
                        title: 'Timeline',
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TimelinePage(),
                          ),
                        ),
                      ),
                      _buildTimelineSection(),

                      // Bottom padding for navigation bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Navigation Bar
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

  /// Build section header with title, dropdown, and "See All" button
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.orange,
                    ),
                  ),
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
                border: Border.all(
                  color: AppColors.lightBlue.withValues(alpha: 0.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: dropdownValue,
                  items: dropdownItems,
                  onChanged: onDropdownChanged,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.darkBlue,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkBlue,
                    fontFamily: 'Poppins',
                  ),
                  isDense: true,
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Build Studio section with horizontal scroll
  Widget _buildStudioSection() {
    if (_isLoadingStudios) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    if (_studios.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No studios in ${userKotaValues.reverse[_selectedCity]}',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _studios.length,
        itemBuilder: (context, index) {
          return HomeStudioCard(
            studio: _studios[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudioDetailPage(
                    studio: _studios[index],
                    isAdmin: false, // TODO: Get from auth state
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Build Events section with horizontal scroll
  Widget _buildEventsSection() {
    // Show loading indicator
    if (_isLoadingEvents) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    final events = _filteredEvents;

    if (events.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            _eventFilter == 'soon'
                ? 'No events this week'
                : _eventFilter == 'later'
                ? 'No upcoming events'
                : 'No events available',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return HomeEventCard(
            event: event,
            posterUrl: _buildPosterUrl(event.poster),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailPage(
                    event: event,
                    baseUrl: AppConstants.baseUrl,
                    currentUsername: '', // TODO: Get from auth
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Build Resources section with horizontal scroll
  Widget _buildResourcesSection() {
    final resources = _filteredResources;

    if (resources.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Text(
            'No resources found',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          return HomeResourceCard(resource: resources[index]);
        },
      ),
    );
  }

  /// Build Sportswear section with horizontal scroll
  Widget _buildSportswearSection() {
    if (_sportswear.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No sportswear available',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _sportswear.length,
        itemBuilder: (context, index) {
          return HomeSportswearCard(product: _sportswear[index]);
        },
      ),
    );
  }

  /// Build Timeline section with vertical scroll (max 3 posts)
  Widget _buildTimelineSection() {
    final posts = _timelinePosts.take(3).toList();

    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Text(
            'No posts yet',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: posts.map((post) {
          return HomeTimelineCard(
            post: post,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
