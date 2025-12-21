import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sportswear_detail_page.dart';
import 'sportswear_brand_form_page.dart';
import 'package:souline_mobile/shared/models/sportswear_model.dart';
import 'package:souline_mobile/shared/widgets/app_header.dart';
import 'package:souline_mobile/shared/widgets/navigation_bar.dart';
import 'package:souline_mobile/shared/widgets/left_drawer.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/user/bookmarks_service.dart';
import 'sportswear_service.dart';

class SportswearPage extends StatefulWidget {
  const SportswearPage({super.key});

  @override
  State<SportswearPage> createState() => _SportswearPageState();
}

class _SportswearPageState extends State<SportswearPage> {
  late SportswearService _service;
  String _searchQuery = '';
  String? _selectedTagFilter;

  List<Product> _brands = [];
  bool _isLoading = true;

  final List<String> _availableTags = ['All', 'Yoga', 'Pilates'];
  bool _isFilterOpen = false;

  bool get isAdmin {
    final request = context.read<CookieRequest>();
    final String username = request.jsonData['username'] ?? '';
    final bool isStaff = request.jsonData['is_staff'] ?? false;
    return isStaff || username == 'soulinestaff';
  }

  @override
  void initState() {
    super.initState();
    _service = SportswearService(context.read<CookieRequest>());
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await _service.fetchBrands(
        tag: (_selectedTagFilter == 'All') ? null : _selectedTagFilter,
        query: _searchQuery,
      );

      if (mounted) {
        response.sort((a, b) => b.rating.compareTo(a.rating));

        setState(() {
          _brands = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _loadBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const LeftDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(
                title: 'Sportswear',
                onSearchChanged: _onSearchChanged,
                onFilterPressed: () => setState(() => _isFilterOpen = !_isFilterOpen),
                showDrawerButton: true,
              ),
              const SizedBox(height: 38),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTagFilter ?? 'All',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.orange
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Top Rated',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.darkBlue))
                  : _brands.isEmpty
                    ? const Center(child: Text("No brands found."))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 120),
                        itemCount: _brands.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _ProductCard(
                              product: _brands[index],
                              onTapDetails: () async {
                                setState(() => _isFilterOpen = false);
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SportswearDetailPage(product: _brands[index])),
                                );
                                if (result == true) _loadBrands();
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: FloatingNavigationBar(currentIndex: 0)),

          if (isAdmin)
            Positioned(
              right: 25,
              bottom: 85,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() => _isFilterOpen = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SportswearBrandFormPage())
                  ).then((_) => _loadBrands());
                },
                backgroundColor: AppColors.orange,
                child: const Icon(Icons.add, color: AppColors.textLight),
              ),
            ),

          if (_isFilterOpen)
            _buildFilterOverlay(),
        ],
      ),
    );
  }

  Widget _buildFilterOverlay() {
    return Positioned(
      top: 190,
      left: 20,
      right: 20,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by Category:', style: TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: _availableTags.map((tag) {
                  final bool isSelected = (_selectedTagFilter ?? 'All') == tag;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTagFilter = (tag == 'All') ? null : tag;
                        _isFilterOpen = false;
                      });
                      _loadBrands();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.darkBlue : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(tag, style: TextStyle(color: isSelected ? Colors.white : AppColors.darkBlue, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTapDetails;

  const _ProductCard({required this.product, required this.onTapDetails});

  @override
  State<_ProductCard> createState() => __ProductCardState();
}

class __ProductCardState extends State<_ProductCard> {
  bool _showReviews = false;
  bool _isBookmarked = false;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) return;

    final service = BookmarksService(request);
    final isBookmarked = await service.isBookmarked(
      BookmarkContentType.sportswear,
      widget.product.id.toString(),
    );

    if (mounted) {
      setState(() => _isBookmarked = isBookmarked);
    }
  }

  Future<void> _toggleBookmark() async {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add a bookmark'), backgroundColor: AppColors.darkBlue),
      );
      return;
    }

    if (_isToggling) return;
    setState(() => _isToggling = true);

    final service = BookmarksService(request);
    final newState = await service.toggleBookmark(
      appLabel: BookmarkAppLabel.sportswear,
      model: BookmarkContentType.sportswear,
      objectId: widget.product.id.toString(),
    );

    if (mounted) {
      setState(() {
        _isBookmarked = newState;
        _isToggling = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'Brand bookmarked' : 'Bookmark removed'),
          backgroundColor: AppColors.darkBlue,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Color _getCategoryColor(String tag) {
    if (tag.toLowerCase().contains('yoga')) return AppColors.lightGreen;
    if (tag.toLowerCase().contains('pilates')) return AppColors.lightBlue;
    return Colors.grey.shade300;
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
      }
    }
  }

  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (rating >= i) {
        stars.add(const Icon(Icons.star, color: AppColors.orange, size: 14));
      } else if (rating >= i - 0.5) {
        stars.add(const Icon(Icons.star_half, color: AppColors.orange, size: 14));
      } else {
        stars.add(const Icon(Icons.star_border, color: AppColors.orange, size: 14));
      }
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final reviews = product.timelineReviews;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    product.thumbnail,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 100, height: 100, color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 30, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: _toggleBookmark,
                            child: Icon(
                              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: AppColors.darkBlue,
                              size: 20
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          product.description,
                          style: TextStyle(fontSize: 12, color: AppColors.darkBlue.withOpacity(0.7)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            ..._buildStarRating(product.rating),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating.toStringAsFixed(1)}/5.0',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue, fontSize: 12),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(product.tag),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                product.tag,
                                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        child: ElevatedButton(
                          onPressed: () {
                            if (product.link.isNotEmpty) {
                              _launchURL(product.link);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No link available')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
                          ),
                          child: const Text('Click here!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: widget.onTapDetails,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Details', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(width: 2),
                    Icon(Icons.north_east, color: AppColors.orange, size: 14),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showReviews = !_showReviews;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Timeline Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkBlue)),
                      Icon(_showReviews ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.darkBlue, size: 20),
                    ],
                  ),
                  if (_showReviews)
                    if (reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No reviews available.', style: TextStyle(color: AppColors.darkBlue.withOpacity(0.6), fontSize: 12)),
                      )
                    else
                      ...reviews.map((review) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildReviewItem(review),
                      )).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.darkBlue.withOpacity(0.2),
                child: const Icon(Icons.person, color: AppColors.darkBlue, size: 16)
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.darkBlue)),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 10, color: AppColors.darkBlue.withOpacity(0.6)),
                      Text(review.location, style: TextStyle(color: AppColors.darkBlue.withOpacity(0.6), fontSize: 10)),
                      const SizedBox(width: 6),
                      const Icon(Icons.star, size: 10, color: AppColors.orange),
                      Text(review.ratingValue.toStringAsFixed(1), style: const TextStyle(color: AppColors.darkBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.reviewText, style: const TextStyle(fontSize: 12, color: AppColors.darkBlue)),
        ],
      ),
    );
  }
}