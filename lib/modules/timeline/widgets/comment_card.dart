import 'package:flutter/material.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/shared/models/comment_entry.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;

  const CommentCard({super.key, required this.comment});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
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

                    SizedBox(height: 8),

                    Text(
                      comment.content,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize:14,
                        ),
                      ),

                    SizedBox(height: 8)
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(
            color: AppColors.textMuted,
            thickness: 0.5,
          ),
        ],
      ),
    ),
  );
}

}