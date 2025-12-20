import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sportswear_brand_form_page.dart';
import 'sportswear_page.dart';
import 'package:souline_mobile/shared/models/sportswear_model.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';

class SportswearDetailPage extends StatefulWidget {
  final Product product;

  const SportswearDetailPage({super.key, required this.product});

  @override
  State<SportswearDetailPage> createState() => _SportswearDetailPageState();
}

class _SportswearDetailPageState extends State<SportswearDetailPage> {
  // Menggunakan warna dari AppColors
  static const Color primaryBrandColor = AppColors.darkBlue;
  static const Color ratingColor = AppColors.orange;
  static const Color accentColor = AppColors.darkBlue;

  final SportswearService _service = SportswearService();
  bool _isDeleting = false;

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SportswearBrandFormPage(brand: widget.product)),
    );

    if (result == true) {
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
      }
    }
  }

  Future<void> _deleteSportswear() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _service.deleteBrand(widget.product.id);

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sportswear deleted successfully!'), backgroundColor: AppColors.darkBlue),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isDeleting,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Delete Sportswear',
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
              ),
              content: _isDeleting
                  ? const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator(color: AppColors.darkBlue))
                    )
                  : Text(
                      'Are you sure you want to delete "${widget.product.name}"? This action cannot be undone.',
                      style: const TextStyle(color: AppColors.darkBlue, fontSize: 14),
                    ),
              actions: <Widget>[
                if (!_isDeleting) ...[
                  TextButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.bold)
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                    ),
                    onPressed: () {
                      setDialogState(() {
                        _isDeleting = true;
                      });
                      _deleteSportswear();
                    },
                  ),
                ],
              ],
            );
          }
        );
      },
    ).then((_) {
      if (mounted && _isDeleting) {
        setState(() {
          _isDeleting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final reviews = product.timelineReviews;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: primaryBrandColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                product.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: primaryBrandColor.withOpacity(0.3),
                        child: const Icon(Icons.shopping_bag, size: 80, color: Colors.white),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _navigateToEdit(context),
                tooltip: 'Edit Brand',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: _showDeleteConfirmationDialog,
                tooltip: 'Delete Brand',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingCard(product),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    icon: Icons.info,
                    title: 'Brand Information',
                    children: [
                      _buildInfoRow('Category', product.tag),
                      _buildInfoRow('Description', product.description),
                      _buildInfoRow('Link', product.link, isLink: true),
                      if (product.adminNotes != null)
                        _buildInfoRow('Admin Notes', product.adminNotes!, isSensitive: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReviewsSection(reviews),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryBrandColor, size: 24),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBrandColor)),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star, color: ratingColor, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Average Rating', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBrandColor)),
                    const SizedBox(width: 4),
                    const Text('/ 5.0', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                final roundedRating = (product.rating * 2).round() / 2;
                if (roundedRating >= starValue) {
                  return const Icon(Icons.star, size: 24, color: ratingColor);
                } else if (roundedRating >= starValue - 0.5) {
                  return const Icon(Icons.star_half, size: 24, color: ratingColor);
                } else {
                  return Icon(Icons.star_border, size: 24, color: ratingColor.withOpacity(0.5));
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false, bool isSensitive = false}) {
    Widget content = Text(
      value,
      style: TextStyle(
        fontSize: 14,
        color: isLink ? AppColors.orange : (isSensitive ? Colors.red.shade800 : primaryBrandColor),
        decoration: isLink ? TextDecoration.underline : TextDecoration.none,
      ),
    );

    if (isLink && value.isNotEmpty) {
      content = InkWell(
        onTap: () => _launchURL(value),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 14, color: isSensitive ? Colors.red : Colors.grey)),
          ),
          Expanded(
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(List<Review> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.message, color: primaryBrandColor, size: 24),
            SizedBox(width: 8),
            Text('Timeline Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBrandColor)),
          ],
        ),
        const SizedBox(height: 16),
        if (reviews.isEmpty)
          const Center(child: Text('No reviews found for this brand.'))
        else
          ...reviews.map((review) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReviewItem(review),
          )).toList(),
      ],
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: primaryBrandColor.withOpacity(0.3)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${review.location} - Rating: ${review.ratingValue.toStringAsFixed(1)}', style: TextStyle(color: primaryBrandColor.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.reviewText, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}