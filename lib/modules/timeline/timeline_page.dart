import 'package:flutter/material.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/attachments.dart';
import 'package:souline_mobile/modules/timeline/post_detail.dart';
import 'package:souline_mobile/modules/timeline/post_form.dart';
import 'package:souline_mobile/modules/timeline/widgets/post_card.dart';
import 'package:souline_mobile/shared/widgets/app_header.dart';
import 'package:souline_mobile/shared/widgets/navigation_bar.dart';
import '../../shared/models/post_entry.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => TimelinePageState();
}

class TimelinePageState extends State<TimelinePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _sortBy = 'latest';
  String _searchQuery = '';
  bool _isFilterVisible = false;
  bool _loading = false;
  bool _hasMore = true;
  int _page = 1;

  // TODO: Replace with actual data from API
  // Mock data for UI development
  final List<Post> _posts = [
    Post(id: 1, username: 'user1', text: 'Hello world!', likeCount: 5, commentCount: 2, likedByUser: false, image: 'https://www.windowslatest.com/wp-content/uploads/2024/10/Windows-XP-4K-modified.jpg'),
    Post(id: 2, username: 'user2', text: 'This is a sample post.', likeCount: 3, commentCount: 1, likedByUser: true),
    Post(id: 3, username: 'user3', text: 'madame morrible flip it around wicked witchhhh bduiwiawhdeiuhduhdeyqj', likeCount: 10, commentCount: 4, likedByUser: false),
  ];

  List<Post> get _filteredPosts {
    if (_searchQuery.isNotEmpty) {
      return _posts.where((post) => post.text.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    } else if (_sortBy == 'latest') {
      final sortedPosts = List<Post>.from(_posts);
      sortedPosts.sort((a, b) => b.id.compareTo(a.id));
      return sortedPosts;
    } else if (_sortBy == 'popular') {
      final sortedPosts = List<Post>.from(_posts);
      sortedPosts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
      return sortedPosts;
    } 
    return _posts;
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _onSortFilterChanged(String filter) {
    setState(() {
      _sortBy = filter;
      _searchQuery = '';
      _searchController.clear();
      _isFilterVisible = false;
    });
  }

  void _toggleFilter() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  void _navigateToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostFormPage()),
    );
  }

  Future<bool> _addComment(int postId, String content) async {
    // Simulate API call to add comment
    await Future.delayed(const Duration(seconds: 1));
    // In real implementation, handle API response and errors
    return true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _sortBy = 'latest';
    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.textLight,
      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(
                title: 'Timeline', 
                onSearchChanged: _onSearchChanged,
                onFilterPressed: _toggleFilter,
              ),
              const SizedBox(height: 30),
              Expanded(
                child: _filteredPosts.isEmpty
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
                            isSearching
                            ? 'No posts found for "$_searchQuery"'
                            : 'No posts available',
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
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 100,
                  ),
                  itemCount: _filteredPosts.length + (isSearching ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (isSearching && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'Found ${_filteredPosts.length} post${_filteredPosts.length != 1 ? 's' : ''} for "$_searchQuery"',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    final postIndex = isSearching ? index - 1 : index;
                    return PostCard(
                      post: _filteredPosts[postIndex],
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PostDetailPage(post: _filteredPosts[postIndex])),
                          )
                      }
                    );
                  },
                )
              ),
            ],
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingNavigationBar(currentIndex: 4),
          ),
        ]
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Adjust for navbar
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostFormPage()),
            );
          },
          backgroundColor: AppColors.teal,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: AppColors.textLight,
            size: 32,
          ),
        ),
      )
    );
  }

  Widget _resourceCard(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AttachmentSelectorPage(type: post.resourceTitle ?? '')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (post.resourceThumbnail != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.resourceThumbnail!, 
                  width: 90, 
                  height: 60, 
                  fit: BoxFit.cover
                ),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                post.resourceTitle ?? '', 
                style: const TextStyle(fontWeight: FontWeight.bold)
              )
            ),
          ],
        ),
      ),
    );
  } 
}