import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/comment_form.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';

class PostCard extends StatefulWidget {
  final Result post;
  final VoidCallback? onTap; // for navigating to PostDetail
  final bool? detail;

  const PostCard({super.key, required this.post, this.onTap, this.detail = false});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isBookmarked = false;

  void _toggleLike() {
    setState(() {
      if (widget.post.likedByUser) {
        widget.post.likedByUser = false;
        widget.post.likeCount -= 1;
      } else {
        widget.post.likedByUser = true;
        widget.post.likeCount += 1;
      }
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
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
                            timeAgo(post.created_at),
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              ),
                          ),
                      ]
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

                    if (post.image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          post.image!,
                          height: detail == true ? 250 : 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    SizedBox(height: detail == true ? 12 : 0,),

                    if (detail == true)
                      Text(
                        DateFormat("h:mm a - d MMM yy").format(post.created_at),
                        style: TextStyle(
                          color: AppColors.textMuted
                        ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentFormPage(post: post),
                              ),
                            );
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
                            post.likedByUser ? Icons.favorite : Icons.favorite_border,
                            color: post.likedByUser ? Colors.red : AppColors.textMuted,
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
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: _isBookmarked ? AppColors.primary : AppColors.textMuted,
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