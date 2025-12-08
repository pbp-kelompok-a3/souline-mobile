import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/shared/models/studio_entry.dart';
import '../studio_detail_page.dart';

class StudioCard extends StatefulWidget {
  final Studio studio;

  const StudioCard({super.key, required this.studio});

  @override
  State<StudioCard> createState() => _StudioCardState();
}

class _StudioCardState extends State<StudioCard> {
  bool _isBookmarked = false;

  Future<void> _openGoogleMaps() async {
    final Uri url = Uri.parse(widget.studio.gmapsLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudioDetailPage(studio: widget.studio),
      ),
    );
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    // TODO: Implement bookmark API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Studio bookmarked' : 'Bookmark removed'),
        backgroundColor: AppColors.darkBlue,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studio = widget.studio;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail on the left
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    studio.thumbnail,
                    width: 140,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 140,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          size: 40,
                          color: AppColors.darkBlue,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.teal,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Studio info on the right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Studio name
                      Text(
                        studio.namaStudio,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Area and City
                      Text(
                        '${studio.area}, ${userKotaValues.reverse[studio.kota] ?? ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkBlue.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Phone number
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              studio.nomorTelepon,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Rating
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            final starValue = index + 1;
                            final roundedRating =
                                (studio.rating * 2).round() / 2;
                            if (roundedRating >= starValue) {
                              return const Icon(
                                Icons.star,
                                size: 16,
                                color: AppColors.orange,
                              );
                            } else if (roundedRating >= starValue - 0.5) {
                              return const Icon(
                                Icons.star_half,
                                size: 16,
                                color: AppColors.orange,
                              );
                            } else {
                              return Icon(
                                Icons.star_border,
                                size: 16,
                                color: AppColors.orange.withOpacity(0.5),
                              );
                            }
                          }),
                          const SizedBox(width: 4),
                          Text(
                            studio.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Google Maps Button
                      SizedBox(
                        height: 32,
                        child: ElevatedButton.icon(
                          onPressed: _openGoogleMaps,
                          icon: const Icon(Icons.map, size: 16),
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Google Maps',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_outward, size: 12),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
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
          // Details text button at bottom right
          Positioned(
            bottom: 12,
            right: 16,
            child: GestureDetector(
              onTap: () => _navigateToDetail(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.orange,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_double_arrow_right,
                    size: 18,
                    color: AppColors.orange,
                  ),
                ],
              ),
            ),
          ),

          // Bookmark button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: _toggleBookmark,
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? AppColors.orange : AppColors.darkBlue,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
