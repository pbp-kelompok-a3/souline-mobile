import 'package:flutter/material.dart';
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
              onPressed: () {
                // deleteComment(comment.id);
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Comment deleted'),
                    backgroundColor: AppColors.darkBlue,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> deleteComment(int id) async {
  //   final url = Uri.parse('http://localhost:8000/timeline/api/delete_comment/$id/');

  //   final response = await http.delete(url);

  //   if (response.statusCode == 200) {
  //     print("Deleted successfully");
  //   } else {
  //     print("Delete failed: ${response.body}");
  //   }
  // }

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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: const Icon(Icons.edit, size: 20, color: AppColors.textMuted),
                          onPressed: () => _navigateToEdit(context),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: const Icon(Icons.delete, size: 20, color: AppColors.textMuted),
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