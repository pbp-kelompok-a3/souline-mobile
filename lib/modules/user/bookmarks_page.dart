import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/left_drawer.dart';
import '../../shared/widgets/navigation_bar.dart';
import '../../shared/widgets/cards/home_studio_card.dart';
import '../../shared/widgets/cards/home_event_card.dart';
import '../../shared/widgets/cards/home_resource_card.dart';
import '../../shared/widgets/cards/home_sportswear_card.dart';
import '../../shared/widgets/cards/home_timeline_card.dart';

import '../../shared/models/studio_entry.dart';
import '../../shared/models/event_model.dart';
import '../../shared/models/resources_entry.dart';
import '../../shared/models/sportswear_model.dart';
import '../../shared/models/post_entry.dart';

import '../studio/studio_detail_page.dart';
import '../events/events_detail.dart';
import '../timeline/post_detail.dart';
import 'bookmarks_service.dart';

/// Bookmarks Page displays all user-bookmarked items across modules
class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  // Search query for filtering bookmarks
  String _searchQuery = '';

  // Bookmarks service
  BookmarksService? _bookmarksService;

  // Bookmarked items
  List<Studio> _bookmarkedStudios = [];
  List<EventModel> _bookmarkedEvents = [];
  List<ResourcesEntry> _bookmarkedResources = [];
  List<Product> _bookmarkedSportswear = [];
  List<Result> _bookmarkedPosts = [];

  // Loading states
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initService();
    });
  }

  /// Initialize service and load bookmarks
  void _initService() {
    final request = context.read<CookieRequest>();
    _bookmarksService = BookmarksService(request);
    _loadBookmarks();
  }

  /// Load all bookmarks
  Future<void> _loadBookmarks() async {
    if (_bookmarksService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch bookmark list
      final bookmarks = await _bookmarksService!.fetchBookmarks();

      // Group by content type
      final studioIds = <String>[];
      final eventIds = <String>[];
      final resourceIds = <String>[];
      final sportswearIds = <String>[];
      final postIds = <String>[];

      for (final bookmark in bookmarks) {
        switch (bookmark.contentType) {
          case BookmarkContentType.studio:
            studioIds.add(bookmark.objectId);
            break;
          case BookmarkContentType.event:
            eventIds.add(bookmark.objectId);
            break;
          case BookmarkContentType.resource:
            resourceIds.add(bookmark.objectId);
            break;
          case BookmarkContentType.sportswear:
            sportswearIds.add(bookmark.objectId);
            break;
          case BookmarkContentType.post:
            postIds.add(bookmark.objectId);
            break;
        }
      }

      // Fetch full data for each type in parallel
      await Future.wait([
        _fetchStudios(studioIds),
        _fetchEvents(eventIds),
        _fetchResources(resourceIds),
        _fetchSportswear(sportswearIds),
        _fetchPosts(postIds),
      ]);

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load bookmarks: $e';
      });
      debugPrint('Error loading bookmarks: $e');
    }
  }

  /// Fetch full studio data for bookmarked IDs
  Future<void> _fetchStudios(List<String> ids) async {
    if (ids.isEmpty) {
      _bookmarkedStudios = [];
      return;
    }

    try {
      final request = context.read<CookieRequest>();
      final response = await request.get('${AppConstants.baseUrl}studio/json/');

      final entry = StudioEntry.fromJson(response);
      final allStudios = <Studio>[];
      for (final city in entry.cities) {
        allStudios.addAll(city.studios);
      }

      _bookmarkedStudios = allStudios.where((s) => ids.contains(s.id)).toList();
    } catch (e) {
      debugPrint('Error fetching studios: $e');
      _bookmarkedStudios = [];
    }
  }

  /// Fetch full event data for bookmarked IDs
  Future<void> _fetchEvents(List<String> ids) async {
    if (ids.isEmpty) {
      _bookmarkedEvents = [];
      return;
    }

    try {
      final url = '${AppConstants.baseUrl}events/json/';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final allEvents = data.map((e) => EventModel.fromJson(e)).toList();

        _bookmarkedEvents = allEvents
            .where((e) => ids.contains(e.id.toString()))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching events: $e');
      _bookmarkedEvents = [];
    }
  }

  /// Fetch full resources data for bookmarked IDs
  Future<void> _fetchResources(List<String> ids) async {
    if (ids.isEmpty) {
      _bookmarkedResources = [];
      return;
    }

    try {
      final url = '${AppConstants.baseUrl}resources/api/json/';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final allResources = data
            .map((e) => ResourcesEntry.fromJson(e))
            .toList();

        _bookmarkedResources = allResources
            .where((r) => ids.contains(r.id.toString()))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching resources: $e');
      _bookmarkedResources = [];
    }
  }

  /// Fetch full sportswear data for bookmarked IDs
  Future<void> _fetchSportswear(List<String> ids) async {
    if (ids.isEmpty) {
      _bookmarkedSportswear = [];
      return;
    }

    try {
      final url = '${AppConstants.baseUrl}sportswear/api/list/';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final allProducts = data.map((e) => Product.fromJson(e)).toList();

        _bookmarkedSportswear = allProducts
            .where((p) => ids.contains(p.id.toString()))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching sportswear: $e');
      _bookmarkedSportswear = [];
    }
  }

  /// Fetch full post data for bookmarked IDs
  Future<void> _fetchPosts(List<String> ids) async {
    if (ids.isEmpty) {
      _bookmarkedPosts = [];
      return;
    }

    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        '${AppConstants.baseUrl}timeline/api/timeline/',
      );

      final postEntry = Post.fromJson(response);
      _bookmarkedPosts = postEntry.results
          .where((p) => ids.contains(p.id.toString()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      _bookmarkedPosts = [];
    }
  }

  /// Filter bookmarks based on search query
  List<Studio> get _filteredStudios {
    if (_searchQuery.isEmpty) return _bookmarkedStudios;
    return _bookmarkedStudios
        .where(
          (s) =>
              s.namaStudio.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.area.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<EventModel> get _filteredEvents {
    if (_searchQuery.isEmpty) return _bookmarkedEvents;
    return _bookmarkedEvents
        .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<ResourcesEntry> get _filteredResources {
    if (_searchQuery.isEmpty) return _bookmarkedResources;
    return _bookmarkedResources
        .where(
          (r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<Product> get _filteredSportswear {
    if (_searchQuery.isEmpty) return _bookmarkedSportswear;
    return _bookmarkedSportswear
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<Result> get _filteredPosts {
    if (_searchQuery.isEmpty) return _bookmarkedPosts;
    return _bookmarkedPosts
        .where(
          (p) =>
              p.text.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.authorUsername.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
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
              // App Header with search
              AppHeader(
                title: 'Bookmarks',
                showDrawerButton: true,
                onSearchChanged: _onSearchChanged,
                filterButton: const SizedBox.shrink(),
              ),
              const SizedBox(height: 25),

              // Scrollable content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.teal),
                      )
                    : _errorMessage != null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: _loadBookmarks,
                        color: AppColors.teal,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // Studio Section
                              _buildSectionHeader('Studio'),
                              _buildStudioSection(),

                              const SizedBox(height: 24),

                              // Events Section
                              _buildSectionHeader('Events'),
                              _buildEventsSection(),

                              const SizedBox(height: 24),

                              // Resources Section
                              _buildSectionHeader('Resources'),
                              _buildResourcesSection(),

                              const SizedBox(height: 24),

                              // Sportswear Section
                              _buildSectionHeader('Sportswear'),
                              _buildSportswearSection(),

                              const SizedBox(height: 24),

                              // Timeline Section
                              _buildSectionHeader('Timeline'),
                              _buildTimelineSection(),

                              // Bottom padding for navigation bar
                              const SizedBox(height: 100),
                            ],
                          ),
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
            child: FloatingNavigationBar(currentIndex: -1),
          ),
        ],
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            style: TextStyle(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBookmarks,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build section header with title only
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Build empty state widget for a section
  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBlue.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Studio section
  Widget _buildStudioSection() {
    final studios = _filteredStudios;

    if (studios.isEmpty) {
      return _buildEmptyState(
        icon: Icons.location_on_outlined,
        message: 'No studios bookmarked yet',
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: studios.length,
        itemBuilder: (context, index) {
          return HomeStudioCard(
            studio: studios[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StudioDetailPage(studio: studios[index], isAdmin: false),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Build Events section
  Widget _buildEventsSection() {
    final events = _filteredEvents;

    if (events.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today_outlined,
        message: 'No events bookmarked yet',
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
            posterUrl: event.poster,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailPage(
                    event: event,
                    baseUrl: AppConstants.baseUrl,
                    currentUsername: '',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Build Resources section
  Widget _buildResourcesSection() {
    final resources = _filteredResources;

    if (resources.isEmpty) {
      return _buildEmptyState(
        icon: Icons.play_circle_outline,
        message: 'No resources bookmarked yet',
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

  /// Build Sportswear section
  Widget _buildSportswearSection() {
    final sportswear = _filteredSportswear;

    if (sportswear.isEmpty) {
      return _buildEmptyState(
        icon: Icons.grid_view_outlined,
        message: 'No sportswear bookmarked yet',
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: sportswear.length,
        itemBuilder: (context, index) {
          return HomeSportswearCard(product: sportswear[index]);
        },
      ),
    );
  }

  /// Build Timeline section
  Widget _buildTimelineSection() {
    final posts = _filteredPosts;

    if (posts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_alt_outlined,
        message: 'No posts bookmarked yet',
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
