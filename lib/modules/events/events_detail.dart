import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/event_model.dart';
import '../studio/studio_page.dart';
import '../studio/studio_detail_page.dart';
import '../studio/studio_service.dart';
import 'add_events.dart';
import '../user/bookmarks_service.dart';
import 'events_service.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel event;
  final String baseUrl;
  final String currentUsername;
  final bool isAdmin;

  const EventDetailPage({
    super.key,
    required this.event,
    required this.baseUrl,
    this.currentUsername = '',
    this.isAdmin = false,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _isDeleting = false;
  bool _isBookmarked = false;
  bool _isTogglingBookmark = false;

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

    if (_isTogglingBookmark) return;
    setState(() => _isTogglingBookmark = true);

    final service = BookmarksService(request);
    final newState = await service.toggleBookmark(
      appLabel: BookmarkAppLabel.events,
      model: BookmarkContentType.event,
      objectId: widget.event.id.toString(),
    );

    if (mounted) {
      setState(() {
        _isBookmarked = newState;
        _isTogglingBookmark = false;
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

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final request = context.read<CookieRequest>();
      final service = EventService(request, AppConstants.baseUrl);
      final success = await service.deleteEvent(widget.event.id);

      if (!mounted) return;
      setState(() => _isDeleting = false);

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Event deleted')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Delete failed')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildPoster() {
    final url = proxiedImageUrl(widget.event.poster);
    final bool isValidUrl = url.startsWith('http');

    if (!isValidUrl) {
      return Container(
        height: 250,
        width: double.infinity,
        color: const Color(0xFFEBEBEB),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      url,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 250,
        color: const Color(0xFFEBEBEB),
        child: const Center(
          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 250,
          color: const Color(0xFFEBEBEB),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner =
        widget.isAdmin ||
        (widget.currentUsername.isNotEmpty &&
            widget.currentUsername == widget.event.createdBy);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Header
                  Stack(
                    children: [
                      _buildPoster(),
                      // Back Button Gradient Overlay
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Back Button
                      Positioned(
                        top: 16,
                        left: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: BackButton(
                            color: AppColors.darkBlue,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      // Bookmark Button (on image)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(
                              _isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: _isBookmarked
                                  ? AppColors.orange
                                  : AppColors.darkBlue,
                            ),
                            onPressed: _toggleBookmark,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.event.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Date
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: AppColors.teal,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Date",
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    "EEEE, dd MMMM yyyy",
                                    "en_US",
                                  ).format(widget.event.date),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Location
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
                                    isAdmin: false,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StudioPage(),
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppColors.orange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Location",
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        widget.event.location.isNotEmpty
                                            ? widget.event.location
                                            : "No location info",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkBlue,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.darkBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_outward,
                                        size: 14,
                                        color: AppColors.darkBlue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Description Header
                        const Text(
                          "About Event",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.event.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF445566),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Action Bar (Edit/Delete) for Owner
            if (isOwner)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isDeleting ? null : _deleteEvent,
                          icon: _isDeleting
                              ? const SizedBox.shrink()
                              : const Icon(Icons.delete),
                          label: _isDeleting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Delete"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddEventPage(editEvent: widget.event),
                              ),
                            ).then((val) {
                              if (val == true) Navigator.pop(context, true);
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Event"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
