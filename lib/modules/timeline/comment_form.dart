import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';

class CommentFormPage extends StatefulWidget {
  final Result post;
  final Comment? comment;

  const CommentFormPage({super.key, required this.post, this.comment});

@override
  State<CommentFormPage> createState() => _CommentFormPageState();
}

class _CommentFormPageState extends State<CommentFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _contentController;

  bool get _isEditing => widget.comment != null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values if editing
    _contentController = TextEditingController(
      text: widget.comment?.content ?? '',
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // void _submitForm() {
  //   if (_formKey.currentState!.validate()) {
  //     // For now, just show success and go back
  //     Navigator.pop(context);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(_isEditing ? 'Comment updated!' : 'Comment posted!'),
  //         backgroundColor: AppColors.darkBlue,
  //       ),
  //     );
  //   }
  // }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();

    try {
      final response = await request.postJson(
        "http://10.0.2.2:8000/timeline/api/${widget.post.id}/comment",
        jsonEncode({
          'content': _contentController.text,
        }),
      );

      if (response['status'] == 'success') { 
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comment added successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add comment.")),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ), 
        foregroundColor: AppColors.textLight,
        backgroundColor: AppColors.darkBlue,
        actions: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 12, 8),
            padding: EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(20)
            ),
            child: TextButton(
            onPressed: () {
              _submitForm();
            },    
            child: Text(
              'Reply',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
                fontWeight: FontWeight.bold
                ),
              ),
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                'Replying to ${widget.post.authorUsername}',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              maxLength: 150,
              maxLines: 5,
              controller: _contentController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon: Container(
                  padding: EdgeInsets.fromLTRB(12, 0, 16, 72),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=${widget.post.authorUsername}&background=random',
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ]
        )
      )
    );
  }
}