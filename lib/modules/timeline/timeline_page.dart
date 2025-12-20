import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/post_detail.dart';
import 'package:souline_mobile/modules/timeline/post_form.dart';
import 'package:souline_mobile/modules/timeline/timeline_service.dart';
import 'package:souline_mobile/modules/timeline/widgets/post_card.dart';
import 'package:souline_mobile/shared/widgets/app_header.dart';
import 'package:souline_mobile/shared/widgets/navigation_bar.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => TimelinePageState();
}

class TimelinePageState extends State<TimelinePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Result> _posts = [];
  bool _loading = true;

  String _sortBy = 'latest';
  String _searchQuery = '';
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final request = context.read<CookieRequest>();
    final service = TimelineService(request);

    try {
      final data = await service.fetchPosts();
      setState(() {
        _posts = data.results;
        _loading = false;
      });
    } catch (e) {
      print("Error loading posts: $e");
    }
  }

  List<Result> get _filteredPosts {
    if (_searchQuery.isNotEmpty) {
      return _posts.where(
            (p) => p.text.toLowerCase().contains(_searchQuery.toLowerCase()),
          ).toList();
    }
    if (_sortBy == 'latest') {
      final sorted = List<Result>.from(_posts);
      sorted.sort((a, b) => b.id.compareTo(a.id));
      return sorted;
    }
    if (_sortBy == 'popular') {
      final sorted = List<Result>.from(_posts);
      sorted.sort((a, b) => b.likeCount.compareTo(a.likeCount));
      return sorted;
    }
    return _posts;
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _onSortChanged(String filter) {
    setState(() {
      _sortBy = filter;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _toggleFilter() { 
    setState(() { 
      _isFilterVisible = !_isFilterVisible; 
    });
  }

  Widget _filterButton({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightBlue : AppColors.cream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.lightBlue,
          )
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? AppColors.darkBlue : AppColors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(
                title: 'Timeline',
                onSearchChanged: _onSearchChanged,
                onFilterPressed: _toggleFilter
              ),

            if (_isFilterVisible)
              Stack(
                alignment: AlignmentGeometry.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(12, 30, 12, 0),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Sort By',
                            style: TextStyle(
                              color: AppColors.darkBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(width: 12),
                          _filterButton(
                            label: "Latest",
                            selected: _sortBy == "latest",
                            onTap: () {
                              _onSortChanged("latest");
                            },
                          ),
                          _filterButton(
                            label: "Popular",
                            selected: _sortBy == "popular",
                            onTap: () {
                              _onSortChanged("popular");
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ),

              SizedBox(height: 30),

              if (isSearching)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Text(
                    'Found ${_filteredPosts.length} post${_filteredPosts.length != 1 ? 's' : ''} for "$_searchQuery"',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              
              Expanded(
                child: _loading 
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _filteredPosts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSearching ? Icons.search_off : Icons.timeline,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isSearching ? 'No posts found for "$_searchQuery"' : 'No posts available',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        itemCount: _filteredPosts.length,
                        itemBuilder: (context, index) {
                          final post = _filteredPosts[index];
                          return PostCard(
                            post: post,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingNavigationBar(currentIndex: 4),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: AppColors.orange,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostFormPage()),
            );
          },
          child: const Icon(
            Icons.add,
            color: AppColors.cream,
            size: 32,
          ),
        ),
      ),
    );
  }
}
