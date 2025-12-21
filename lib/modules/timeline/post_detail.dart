import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/post_form.dart';
import 'package:souline_mobile/modules/timeline/comment_form.dart'; 
import 'package:souline_mobile/modules/timeline/timeline_service.dart';
import 'package:souline_mobile/modules/timeline/widgets/comment_card.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';
import 'package:souline_mobile/modules/timeline/widgets/post_card.dart';

class PostDetailPage extends StatefulWidget {
  final Result post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late int _commentCount;
  late List<Comment> _comments;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _commentCount = widget.post.commentCount;
    _comments = widget.post.comments;
  }

  Future<void> _refreshComments() async {
    setState(() => _isLoading = true);
    try {
      final request = context.read<CookieRequest>();
      final newComments = await TimelineService(request).fetchComments(widget.post.id); 
      
      if (mounted) {
        setState(() {
          _comments = newComments;
          _commentCount = newComments.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToAddComment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentFormPage(post: widget.post),
      ),
    );

    if (result == true) {
      _refreshComments();
    }
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => PostFormPage(post: widget.post))
    );

    if (result == true && context.mounted) {
      _refreshComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated')),
      );
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
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final success = await service.deletePost(widget.post.id);

                if (context.mounted) {
                  Navigator.of(context).pop(); 

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
    widget.post.commentCount = _commentCount;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _commentCount); 
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          foregroundColor: AppColors.cream,
          title: const Text(
            'Post',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.darkBlue,
          actions: [
            if (widget.post.isOwner) ... [
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
        
        body: RefreshIndicator(
          onRefresh: _refreshComments,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              PostCard(
                post: widget.post, 
                detail: true,
                onCommentTap: _navigateToAddComment, 
              ),

              const Padding(
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

              const SizedBox(height: 12),

              if (_comments.isNotEmpty) 
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return CommentCard(
                        post: widget.post, 
                        comment: comment,
                        onRefresh: _refreshComments, 
                      );
                    },
                  ),
                ),
              
              if (_comments.isEmpty) 
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
                  child: const Text(
                    'No comments yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}