import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/event_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../studio/studio_page.dart';
import '../../studio/studio_detail_page.dart';
import '../../studio/studio_service.dart';
import '../../user/bookmarks_service.dart';

class EventCard extends StatefulWidget {
  final EventModel event;
  final String posterUrl;
  final VoidCallback onDetail;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isOwner;

  const EventCard({
    super.key,
    required this.event,
    required this.posterUrl,
    required this.onDetail,
    this.onEdit,
    this.onDelete,
    this.isOwner = false,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
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
    // Note: 'event' is the generic model name used in bookmarks backend
    // 'events' is the app_label
    final isBookmarked = await service.isBookmarked(
      BookmarkContentType.event,
      widget.event.id.toString(),
    );

    if (mounted) {
      setState(() => _isBookmarked = isBookmarked);
    }
  }

  Future<void> _toggleBookmark() async {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add a bookmark'),
          backgroundColor: AppColors.darkBlue,
        ),
      );
      return;
    }

    if (_isToggling) return;
    setState(() => _isToggling = true);

    final service = BookmarksService(request);
    final newState = await service.toggleBookmark(
      appLabel: BookmarkAppLabel.events,
      model: BookmarkContentType.event,
      objectId: widget.event.id.toString(),
    );

    if (mounted) {
      setState(() {
        _isBookmarked = newState;
        _isToggling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked ? 'Event bookmarked' : 'Bookmark removed',
          ),
          backgroundColor: AppColors.darkBlue,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildPoster() {
    // Use proxy for robust image loading
    // Function is imported from studio module
    final url = proxiedImageUrl(widget.posterUrl);

    // Basic URL validation
    final bool isValidUrl = url.startsWith('http');

    if (!isValidUrl) {
      return Container(
        width: 120,
        color: const Color(0xFFEBEBEB),
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      url,
      width: 120,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 120,
        color: const Color(0xFFEBEBEB),
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 120,
          color: const Color(0xFFEBEBEB),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0ECE5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: _buildPoster(),
                ),

                // Right content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 24.0),
                          child: Text(
                            widget.event.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF2E4057),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat(
                            "dd MMMM yyyy",
                            "en_US",
                          ).format(widget.event.date),
                          style: const TextStyle(
                            color: Color(0xFF7A8D9C),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Location link
                        if (widget.event.location.isNotEmpty)
                          GestureDetector(
                            onTap: () async {
                              final locationId = widget.event.locationId;
                              if (locationId == null || locationId.isEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const StudioPage(),
                                  ),
                                );
                                return;
                              }

                              final request = context.read<CookieRequest>();
                              // Show generic loading if needed, or just await
                              final service = StudioService(request);
                              final studio = await service.fetchStudioById(
                                locationId,
                              );

                              if (!context.mounted) return;

                              if (studio != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StudioDetailPage(
                                      studio: studio,
                                      isAdmin: false, // Per user request
                                    ),
                                  ),
                                );
                              } else {
                                // Fallback if studio not found
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const StudioPage(),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              widget.event.location,
                              style: const TextStyle(
                                color: AppColors.orange,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),

                        // Description
                        Text(
                          widget.event.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF445566),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: widget.onDetail,
                              child: const Text(
                                'Detail',
                                style: TextStyle(
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (widget.isOwner) const SizedBox(width: 8),
                            if (widget.isOwner && widget.onEdit != null)
                              InkWell(
                                onTap: widget.onEdit,
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                ),
                              ),
                            if (widget.isOwner && widget.onDelete != null)
                              InkWell(
                                onTap: widget.onDelete,
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bookmark Button (Top Right)
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: _toggleBookmark,
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? AppColors.orange : AppColors.darkBlue,
                size: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
