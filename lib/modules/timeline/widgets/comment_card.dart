import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/comment_form.dart';
import 'package:souline_mobile/modules/timeline/timeline_service.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final Result post;
  final VoidCallback onRefresh;

  const CommentCard({
    super.key, 
    required this.comment, 
    required this.post,
    required this.onRefresh, 
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentFormPage(
          post: widget.post, 
          comment: widget.comment
        )
      ),
    );

    if (result == true) {
      widget.onRefresh();
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final request = context.read<CookieRequest>();
    final service = TimelineService(request);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cream,
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final success = await service.deleteComment(widget.comment.id);

                if (context.mounted) {
                  Navigator.of(context).pop(); 

                  if (success) {
                    widget.onRefresh(); 

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment deleted'),
                        backgroundColor: AppColors.darkBlue,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete comment'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;

    return GestureDetector(
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
                    'https://ui-avatars.com/api/?name=${comment.authorUsername}&background=random',
                  ),
                  radius: 16,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorUsername,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        comment.content,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize:14,
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.edit, size: 16, color: AppColors.textMuted),
                            onPressed: () => _navigateToEdit(context),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.delete, size: 16, color: AppColors.textMuted),
                            onPressed: () => _showDeleteConfirmation(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8)
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}