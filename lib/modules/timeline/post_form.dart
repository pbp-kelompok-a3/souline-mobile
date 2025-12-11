import 'package:flutter/material.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/post_form.dart';
import 'package:souline_mobile/modules/timeline/widgets/comment_card.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';
import 'package:souline_mobile/modules/timeline/widgets/post_card.dart';

class PostFormPage extends StatelessWidget {
  final Post? post;

  const PostFormPage({super.key, this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textLight,
      appBar: AppBar(
        foregroundColor: AppColors.textLight,
        title: const Text('Create Post',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: AppColors.darkBlue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'What\'s on your mind?',
            ),
          ),

          const SizedBox(height: 16),
        ]
      )
    );
  }
}