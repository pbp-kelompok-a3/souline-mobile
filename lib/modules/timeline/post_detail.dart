import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/post_form.dart';
import 'package:souline_mobile/modules/timeline/timeline_service.dart';
import 'package:souline_mobile/modules/timeline/widgets/comment_card.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';
import 'package:souline_mobile/modules/timeline/widgets/post_card.dart';

class PostDetailPage extends StatelessWidget {
  final Result post;

  const PostDetailPage({super.key, required this.post});

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PostFormPage(post: post)));

    if (result == true && context.mounted) {
      Navigator.pop(context, true); 
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
          title: const Text('Delete Post'),
          content: Text('Are you sure you want to delete post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final success = await service.deletePost(post.id);

                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog

                  if (success) {
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post deleted'),
                        backgroundColor: AppColors.darkBlue,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete post'),
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
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        foregroundColor: AppColors.cream,
        title: const Text('Post',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: AppColors.darkBlue,
        actions: [
          if (post.isOwner) ... [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEdit(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ]
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          PostCard(
            post: post,
            detail: true,
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Comments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),

          SizedBox(height: 12),

          if (post.commentCount > 0) 
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                itemCount: post.comments.length,
                itemBuilder: (context, index) {
                  final comment = post.comments[index];
                  return CommentCard(post: post, comment: comment);
                },
              ),
            ),
          
          if (post.commentCount == 0) 
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 50, horizontal: 16),
              child: Text(
                'No comments yet',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      )
    );
  }
}