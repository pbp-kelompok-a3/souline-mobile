import 'package:flutter/material.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/comment_form.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onTap; // for navigating to PostDetail
  final bool? detail;

  const PostCard({super.key, required this.post, this.onTap, this.detail = false});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
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
      widget.post.bookmarkedByUser = !widget.post.bookmarkedByUser;
    });
  }

  @override
  Widget build(BuildContext context) {
  final post = widget.post;
  final detail = widget.detail;

  return GestureDetector(
    onTap: widget.onTap,
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://ui-avatars.com/api/?name=${post.username}&background=random',
                ),
                radius: detail == true ? 16 : 20,
              ),

              SizedBox(width: detail == true ? 16 : 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: detail == true ? 18 : 14,
                        ),
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

                    SizedBox(height: detail == true ? 20 : 10),

                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.comment_outlined,
                            color: AppColors.textMuted,
                            size: detail == true ? 28 : 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentFormPage(),
                              ),
                            );
                          },
                        ),

                        const Spacer(),

                        IconButton(
                          icon: Icon(
                            post.likedByUser ? Icons.favorite : Icons.favorite_border,
                            color: post.likedByUser ? Colors.red : AppColors.textMuted,
                            size: detail == true ? 28 : 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: _toggleLike,
                        ),
                        SizedBox(width: detail == true ? 8 : 4),
                        Text(
                          "${post.likeCount}",
                          style: TextStyle(
                            fontSize: detail == true ? 16 : 12,
                            color: AppColors.textMuted,
                          ),
                        ),

                        SizedBox(width: 30),

                        IconButton(
                          icon: Icon(
                            post.bookmarkedByUser ? Icons.bookmark : Icons.bookmark_border,
                            color: post.bookmarkedByUser ? AppColors.primary : AppColors.textMuted,
                            size: detail == true ? 28 : 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: _toggleBookmark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(
            color: detail == true ? AppColors.textDark : AppColors.textMuted,
            thickness: detail == true ? 1 : 0.5,
          ),
        ],
      ),
    ),
  );
}

}