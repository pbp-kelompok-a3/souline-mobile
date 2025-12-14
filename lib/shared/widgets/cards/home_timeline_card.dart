import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/post_entry.dart';

class HomeTimelineCard extends StatefulWidget {
  final Result post;
  final VoidCallback? onTap;

  const HomeTimelineCard({super.key, required this.post, this.onTap});

  @override
  State<HomeTimelineCard> createState() => _HomeTimelineCardState();
}

class _HomeTimelineCardState extends State<HomeTimelineCard> {
  bool _isBookmarked = false;

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    // TODO: Implement bookmark API
  }

  String _getInitials(String username) {
    if (username.isEmpty) return '??';
    final parts = username.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and username
            Row(
              children: [
                // Circle avatar with initials
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.teal,
                  child: Text(
                    _getInitials(post.authorUsername),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Username
                Expanded(
                  child: Text(
                    post.authorUsername,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Bookmark button
                IconButton(
                  onPressed: _toggleBookmark,
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _isBookmarked
                        ? AppColors.orange
                        : AppColors.textMuted,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Post content
            Text(
              post.text,
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Like and comment counts
            Row(
              children: [
                // Likes
                Icon(
                  post.likedByUser ? Icons.favorite : Icons.favorite_border,
                  color: post.likedByUser ? Colors.red : AppColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),

                const SizedBox(width: 16),

                // Comments
                Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.commentCount}',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
