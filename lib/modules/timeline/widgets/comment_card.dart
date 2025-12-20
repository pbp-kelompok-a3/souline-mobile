import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/comment_form.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final Result post;

  const CommentCard({super.key, required this.comment, required this.post});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentFormPage(post: widget.post, comment: widget.comment,)),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final request = context.read<CookieRequest>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cream,
          title: const Text('Delete Comment'),
          content: Text(
            'Are you sure you want to delete comment?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final success = await deleteComment(request, widget.comment.id);

                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog

                  if (success) {
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

  Future<bool> deleteComment(CookieRequest request, int commentId) async {
    final url = "${AppConstants.baseUrl}timeline/api/comment/$commentId/delete/";

    try {
      final response = await request.postJson(url, null);

      if (response['status'] == 'success') {
        return true;
      } else {
        print("Delete failed: ${response['message']}");
        return false;
      }
    } catch (e) {
      print("Error deleting comment: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
  final comment = widget.comment;

  return GestureDetector(
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
                  'https://ui-avatars.com/api/?name=${comment.authorUsername}&background=random',
                ),
                radius: 16,
              ),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorUsername,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        ),
                      ),

                    SizedBox(height: 4),

                    Text(
                      comment.content,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize:14,
                        ),
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: const Icon(Icons.edit, size: 16, color: AppColors.textMuted),
                          onPressed: () => _navigateToEdit(context),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: const Icon(Icons.delete, size: 16, color: AppColors.textMuted),
                          onPressed: () => _showDeleteConfirmation(context),
                        ),
                      ]
                    ),

                    SizedBox(height: 8)
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10)
        ],
      ),
    ),
  );
}

}