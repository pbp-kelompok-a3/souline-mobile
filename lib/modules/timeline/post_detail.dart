import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/post_form.dart';
import 'package:souline_mobile/modules/timeline/widgets/comment_card.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';
import 'package:souline_mobile/modules/timeline/widgets/post_card.dart';

class PostDetailPage extends StatelessWidget {
  final Result post;

  const PostDetailPage({super.key, required this.post});

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostFormPage(post: post)),
    );
  }

  Future<void> deletePost(int id) async {
    final url = Uri.parse('http://localhost:8000/timeline/api/delete_post/$id/');

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Deleted successfully");
    } else {
      print("Delete failed: ${response.body}");
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cream,
          title: const Text('Delete Post'),
          content: Text(
            'Are you sure you want to delete post?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deletePost(post.id);
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Post deleted'),
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
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
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