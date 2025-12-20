import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sportswear_detail_page.dart';
import 'sportswear_brand_form_page.dart';
import 'package:souline_mobile/shared/models/sportswear_model.dart';
import 'package:souline_mobile/shared/widgets/app_header.dart';
import 'package:souline_mobile/shared/widgets/navigation_bar.dart';
import 'sportswear_service.dart';

const Color darkBlueColor = Color(0xFF446178);
const Color lightBeigeColor = Color(0xFFFFFBF0);
const Color orangeColor = Color(0xFFFFA04D);
const Color lightGreenColor = Color(0xFFB4DEBD);
const Color lightBlueColor = Color(0xFF8BC4DA);
const Color whiteColor = Color(0xFFFFFFFF);

//  WIDGET HALAMAN UTAMA
class SportswearPage extends StatefulWidget {
  const SportswearPage({super.key});

  @override
  State<SportswearPage> createState() => _SportswearPageState();
}

class _SportswearPageState extends State<SportswearPage> {
  final SportswearService _service = SportswearService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedTagFilter;

  late Future<List<Product>> _brandsFuture;
  final List<String> _availableTags = ['All', 'Yoga', 'Pilates'];

  final int _navigationIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  void _loadBrands() {
    setState(() {
      _brandsFuture = _service.fetchBrands(
        tag: _selectedTagFilter,
        query: _searchQuery,
      );
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _loadBrands();
    });
  }

  void _navigateToFormPage({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SportswearBrandFormPage(brand: product),
      ),
    );

    if (result == true) {
      _loadBrands();
    }
  }

  void _showTagFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Filter by Category',
            style: TextStyle(color: darkBlueColor),
          ),
          backgroundColor: whiteColor,
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableTags.length,
              itemBuilder: (context, index) {
                final tag = _availableTags[index];
                return RadioListTile<String>(
                  title: Text(
                    tag,
                    style: const TextStyle(color: darkBlueColor),
                  ),
                  value: tag,
                  groupValue: _selectedTagFilter ?? 'All',
                  activeColor: orangeColor,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedTagFilter = value;
                      Navigator.pop(context);
                      _loadBrands();
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeigeColor,

      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(
                title: 'Sportswear',
                onSearchChanged: _onSearchChanged,
                onFilterPressed: _showTagFilterDialog,
              ),

              const SizedBox(height: 40),

              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _brandsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: darkBlueColor),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Failed to load data: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          _searchQuery.isEmpty && _selectedTagFilter == null
                              ? 'No brands found.'
                              : 'No results found.',
                          style: const TextStyle(color: darkBlueColor),
                        ),
                      );
                    }

                    final brands = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 120),
                      itemCount: brands.length,
                      itemBuilder: (context, index) {
                        final product = brands[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _ProductCard(
                            product: product,
                            onTapDetails: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SportswearDetailPage(product: product),
                                ),
                              );
                              if (result == true) {
                                _loadBrands();
                              }
                            },
                          ),
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
            child: FloatingNavigationBar(currentIndex: _navigationIndex),
          ),

          Positioned(
            right: 25,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: () => _navigateToFormPage(),
              backgroundColor: orangeColor,
              child: const Icon(Icons.add, color: whiteColor),
            ),
          ),
        ],
      ),
    );
  }
}

// PRODUCT CARD
class _ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTapDetails;

  const _ProductCard({required this.product, required this.onTapDetails});

  @override
  State<_ProductCard> createState() => __ProductCardState();
}

class __ProductCardState extends State<_ProductCard> {
  bool _showReviews = false;

  // Fungsi Helper: Warna Kategori
  Color _getCategoryColor(String tag) {
    if (tag.toLowerCase().contains('yoga')) return lightGreenColor;
    if (tag.toLowerCase().contains('pilates')) return lightBlueColor;
    return Colors.grey.shade300; // Default
  }

  // Fungsi Helper: Membuka Link Eksternal
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
      }
    }
  }

  // Fungsi Helper: Render Bintang
  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (rating >= i) {
        stars.add(const Icon(Icons.star, color: orangeColor, size: 14));
      } else if (rating >= i - 0.5) {
        stars.add(const Icon(Icons.star_half, color: orangeColor, size: 14));
      } else {
        stars.add(const Icon(Icons.star_border, color: orangeColor, size: 14));
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
      color: whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Info Produk
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Gambar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    product.thumbnail,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul & Bookmark
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkBlueColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.bookmark_border,
                            color: darkBlueColor.withOpacity(0.7),
                            size: 20,
                          ),
                        ],
                      ),

                      // Deskripsi Singkat
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: darkBlueColor.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // RATING & CATEGORY
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            // Rating Stars
                            ..._buildStarRating(product.rating),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating.toStringAsFixed(1)}/5.0',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: darkBlueColor,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Kategori
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(product.tag),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                product.tag,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: whiteColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Tombol CLICK HERE
                      SizedBox(
                        child: ElevatedButton(
                          onPressed: () {
                            if (product.link.isNotEmpty) {
                              _launchURL(product.link);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No link available'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlueColor,
                            foregroundColor: whiteColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Click here!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Link DETAILS
          Padding(
            padding: const EdgeInsets.only(right: 12.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: widget.onTapDetails,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        color: orangeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.north_east, color: orangeColor, size: 14),
                  ],
                ),
              ),
            ),
          ),

          // TIMELINE REVIEWS
          GestureDetector(
            onTap: () {
              setState(() {
                _showReviews = !_showReviews;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Timeline Reviews',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: darkBlueColor,
                        ),
                      ),
                      Icon(
                        _showReviews
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: darkBlueColor,
                        size: 20,
                      ),
                    ],
                  ),
                  if (_showReviews)
                    if (reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Belum ada ulasan.',
                          style: TextStyle(
                            color: darkBlueColor.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      ...reviews
                          .map(
                            (review) => Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: _buildReviewItem(review),
                            ),
                          )
                          .toList(),
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
                backgroundColor: darkBlueColor.withOpacity(0.2),
                child: const Icon(Icons.person, color: darkBlueColor, size: 16),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: darkBlueColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 10,
                        color: darkBlueColor.withOpacity(0.6),
                      ),
                      Text(
                        review.location,
                        style: TextStyle(
                          color: darkBlueColor.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.star, size: 10, color: orangeColor),
                      Text(
                        review.ratingValue.toStringAsFixed(1),
                        style: const TextStyle(
                          color: darkBlueColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.reviewText,
            style: const TextStyle(fontSize: 12, color: darkBlueColor),
          ),
        ],
      ),
    );
  }
}
