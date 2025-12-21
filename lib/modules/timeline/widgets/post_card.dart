import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/comment_form.dart';
import 'package:souline_mobile/modules/timeline/timeline_service.dart';
import 'package:souline_mobile/modules/user/bookmarks_service.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends StatefulWidget {
  final Result post;
  final VoidCallback? onTap; // for navigating to PostDetail
  final bool? detail;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.detail = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isBookmarked = false;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  /// Check if this post is bookmarked
  Future<void> _checkBookmarkStatus() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) return;

    final service = BookmarksService(request);
    final isBookmarked = await service.isBookmarked(
      BookmarkContentType.post,
      widget.post.id.toString(),
    );

    if (mounted) {
      setState(() => _isBookmarked = isBookmarked);
    }
  }

  Future<void> _toggleLike() async {
    final request = context.read<CookieRequest>();
    final service = TimelineService(request);

    setState(() {
      if (widget.post.likedByUser) {
        widget.post.likedByUser = false;
        widget.post.likeCount -= 1;
      } else {
        widget.post.likedByUser = true;
        widget.post.likeCount += 1;
      }
    });

    try {
      await service.toggleLike(widget.post.id);
    } catch (e) {
      setState(() {
        if (widget.post.likedByUser) {
          widget.post.likedByUser = false;
          widget.post.likeCount -= 1;
        } else {
          widget.post.likedByUser = true;
          widget.post.likeCount += 1;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
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
      appLabel: BookmarkAppLabel.timeline,
      model: BookmarkContentType.post,
      objectId: widget.post.id.toString(),
    );

    if (mounted) {
      setState(() {
        _isBookmarked = newState;
        _isToggling = false;
      });
    }
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 10) {
      return "Just now";
    } else if (diff.inMinutes < 1) {
      return "${diff.inSeconds}s";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h";
    } else if (diff.inDays < 7) {
      return "${diff.inDays}d";
    } else {
      // fallback to formatted date
      return DateFormat("d MMM yyyy").format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final detail = widget.detail;
    Map<String, dynamic>? attachment = post.attachment;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://ui-avatars.com/api/?name=${post.authorUsername}&background=random',
                  ),
                  radius: 20,
                ),

                SizedBox(width: detail == true ? 16 : 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            post.authorUsername,
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: detail == true ? 18 : 14,
                            ),
                          ),
                          if (detail == false)
                            Text(
                              timeAgo(post.createdAt),
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 8),

                      Text(
                        post.text,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: detail == true ? 18 : 14,
                        ),
                      ),

                      SizedBox(height: detail == true ? 12 : 8),

                      if (post.image != null && post.image!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            post.image!,
                            height: detail == true ? 250 : 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      SizedBox(height: detail == true ? 10 : 0),

                      if (attachment != null)
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.textLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.25),
                              ),
                            ),
                            child: ListTile(
                              leading: Image.network(
                                attachment['thumbnail'] ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                attachment['name'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                attachment['tag'] ??
                                    attachment['type'] ??
                                    'Attachment',
                              ),
                              onTap: () async {
                                final url = attachment['link'] ?? '';

                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(
                                    Uri.parse(url),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                      SizedBox(height: detail == true ? 8 : 0),

                      if (detail == true)
                        Text(
                          DateFormat(
                            "h:mm a - d MMM yy",
                          ).format(post.createdAt),
                          style: TextStyle(color: AppColors.textMuted),
                        ),

                      SizedBox(height: detail == true ? 8 : 0),

                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.comment_outlined,
                              color: AppColors.textMuted,
                              size: detail == true ? 24 : 20,
                            ),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final request = context.read<CookieRequest>();
                              if (request.loggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CommentFormPage(post: post),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "You must be logged in to perform this action.",
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                          Text(
                            "${post.commentCount}",
                            style: TextStyle(
                              fontSize: detail == true ? 16 : 12,
                              color: AppColors.textMuted,
                            ),
                          ),

                          Spacer(),

                          IconButton(
                            icon: Icon(
                              post.likedByUser
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: post.likedByUser
                                  ? Colors.red
                                  : AppColors.textMuted,
                              size: detail == true ? 24 : 20,
                            ),
                            constraints: const BoxConstraints(),
                            onPressed: _toggleLike,
                          ),
                          Text(
                            "${post.likeCount}",
                            style: TextStyle(
                              fontSize: detail == true ? 16 : 12,
                              color: AppColors.textMuted,
                            ),
                          ),

                          SizedBox(width: detail == true ? 30 : 20),

                          IconButton(
                            icon: Icon(
                              _isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: _isBookmarked
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: detail == true ? 24 : 20,
                            ),
                            onPressed: _toggleBookmark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Divider(
              color: detail == true ? AppColors.textDark : AppColors.textMuted,
              thickness: detail == true ? 1 : 0.5,
              height: detail == true ? 24 : 10,
            ),
          ],
        ),
      ),
    );
  }
}
