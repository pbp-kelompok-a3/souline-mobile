import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:souline_mobile/shared/models/resources_entry.dart';
import 'package:souline_mobile/modules/user/bookmarks_service.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';

class ResourcesCard extends StatefulWidget {
  final ResourcesEntry resource;
  final VoidCallback? onTapDetail;
  final VoidCallback? onTapBookmark;
  final bool showAdminActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ResourcesCard({
    super.key,
    required this.resource,
    this.onTapDetail,
    this.onTapBookmark,
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ResourcesCard> createState() => _ResourcesCardState();
}

class _ResourcesCardState extends State<ResourcesCard> {
  bool _isBookmarked = false;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  /// Check if this resource is bookmarked
  Future<void> _checkBookmarkStatus() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) return;

    final service = BookmarksService(request);
    final isBookmarked = await service.isBookmarked(
      BookmarkContentType.resource,
      widget.resource.id.toString(),
    );

    if (mounted) {
      setState(() => _isBookmarked = isBookmarked);
    }
  }

  /// Toggle bookmark status
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
      appLabel: BookmarkAppLabel.resources,
      model: BookmarkContentType.resource,
      objectId: widget.resource.id.toString(),
    );

    if (mounted) {
      setState(() {
        _isBookmarked = newState;
        _isToggling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked ? 'Resource bookmarked' : 'Bookmark removed',
          ),
          backgroundColor: AppColors.darkBlue,
          duration: const Duration(seconds: 1),
        ),
      );
    }

    // Also call the external callback if provided
    widget.onTapBookmark?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === THUMBNAIL AREA ===
          GestureDetector(
            onTap: widget.onTapDetail,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Stack(
                children: [
                  if (widget.resource.thumbnailUrl.isNotEmpty)
                    Image.network(
                      widget.resource.thumbnailUrl,
                      width: double.infinity,
                      height: 155,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const _ThumbnailFallback(height: 155),
                    )
                  else
                    const _ThumbnailFallback(height: 155),
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (widget.showAdminActions)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          _AdminPillButton(
                            label: "Edit",
                            color: Colors.blue,
                            icon: Icons.edit,
                            onTap: widget.onEdit,
                          ),
                          const SizedBox(width: 8),
                          _AdminPillButton(
                            label: "Delete",
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: widget.onDelete,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // WHITE AREA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE + BOOKMARK
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TITLE
                    SizedBox(
                      width: 200,
                      child: Text(
                        widget.resource.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF233654),
                        ),
                      ),
                    ),

                    // BOOKMARK BUTTON - Now toggles!
                    GestureDetector(
                      onTap: _toggleBookmark,
                      child: Icon(
                        _isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: _isBookmarked
                            ? AppColors.orange
                            : const Color(0xFF233654),
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ROW: description + "Detail"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // DESCRIPTION
                    Expanded(
                      child: Text(
                        widget.resource.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7A7C89),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // "DETAIL" BUTTON
                    GestureDetector(
                      onTap: widget.onTapDetail,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Detail",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF9A14A),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_outward,
                            size: 10,
                            color: Color(0xFFF9A14A),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPillButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _AdminPillButton({
    required this.label,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  final double height;
  const _ThumbnailFallback({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Color(0xFF94A3B8)),
    );
  }
}
