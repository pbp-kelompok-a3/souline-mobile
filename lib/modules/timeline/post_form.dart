import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';

class PostFormPage extends StatefulWidget {
  final Result? post;

  const PostFormPage({super.key, this.post});

@override
  State<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _textController;
  late TextEditingController _imageController;
  late TextEditingController _attachmentController;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values if editing
    _textController = TextEditingController(
      text: widget.post?.text ?? '',
    );
    _imageController = TextEditingController(
      text: widget.post?.image ?? '',
    );
    // _attachmentController = TextEditingController(
    //   text: widget.post?.attachments ?? '',
    //   );
  }

  @override
  void dispose() {
    _textController.dispose();
    _imageController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // For now, just show success and go back
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Post updated!' : 'Post created!'),
          backgroundColor: AppColors.darkBlue,
        ),
      );
    }
  }

  // Future<void> _submitForm(Post post) async {
  //   final response = await http.get(Uri.parse('http://localhost:8000/timeline/api/create_post/'));

  //   if (_formKey.currentState!.validate()) {
  //     if (response.statusCode == 200) {
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(_isEditing ? 'Post updated!' : 'Post created!'),
  //           backgroundColor: AppColors.darkBlue,
  //         ),
  //       ); 
  //     } else {
  //       throw Exception('Failed to post');
  //     }
  //   }
  // }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageController.text = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ), 
        foregroundColor: AppColors.cream,
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
              'Post',
              style: TextStyle(
                color: AppColors.cream,
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
            TextFormField(
              maxLength: 200,
              maxLines: 8,
              controller: _textController,
              validator: (value) {
                if (value == null && _imageController.text == '' || value!.isEmpty && _imageController.text == '') {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                hintStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon: Container(
                  padding: EdgeInsets.fromLTRB(12, 0, 16, 150),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=${widget.post?.authorUsername}&background=random',
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

            if (_imageController.text.isNotEmpty)
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageController.text,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.all(24),
                  onPressed: () {
                    setState(() {
                      _imageController.text = '';
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    size: 24,
                    color: AppColors.cream,
                    ))
              ]
            ),

            SizedBox(height: 20),
            Divider(
              height: 4,
              color: AppColors.textMuted,
              thickness: 1,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.image, color: AppColors.darkBlue),
                  onPressed: () {
                    _pickImage();
                  }
                ),
                IconButton(
                  icon: Icon(Icons.video_library, color: AppColors.darkBlue),
                  onPressed: () {}
                ),
                IconButton(
                  icon: Icon(Icons.shopping_bag, color: AppColors.darkBlue),
                  onPressed: () {}
                ),
              ],
            ),
            Divider(
              height: 4,
              color: AppColors.textMuted,
              thickness: 1,
            ),
          ]
        )
      )
    );
  }
}