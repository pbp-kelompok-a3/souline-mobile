import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/modules/timeline/attachments.dart';
import 'package:souline_mobile/modules/timeline/timeline_service.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

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

  Map<String, dynamic>? attachments;
  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.post?.text ?? '');
    _imageController = TextEditingController(text: widget.post?.image ?? '');
    
    if (widget.post != null && widget.post!.attachment != null) {
      attachments = Map<String, dynamic>.from(widget.post!.attachment!);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();
        final timelineService = TimelineService(request);

    try {
      await timelineService.createPost(
        text: _textController.text,
        image: _imageController.text.isNotEmpty ? _imageController.text : null,
        attachment: attachments, 
      );

      if (!mounted) return;
      Navigator.pop(context, true); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Post updated!' : 'Post created!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageController.text = image.path;
      });
    }
  }

  Future<void> _openAttachmentSelector(String type) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttachmentSelectorPage(type: type),
      ),
    );

    if (result != null) {
      setState(() {
        attachments = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachment = attachments;

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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                maxLength: 200,
                maxLines: 5,
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
                    padding: EdgeInsets.fromLTRB(12, 10, 16, 150),
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

              if (attachment != null)
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.25)),
                      ),
                      child: ListTile(
                        leading: Image.network(
                          attachment['thumbnail'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(attachment['name'] ?? '', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold),
                            ),
                        subtitle: Text(attachment['tag'] ?? attachment['type'] ?? 'Attachment'),
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.all(24),
                    onPressed: () {
                      setState(() {
                        attachments = null;
                      });
                    },
                    icon: Icon(
                      Icons.close,
                      size: 24,
                      color: AppColors.textMuted,
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
                    onPressed: () {
                      _openAttachmentSelector("Resources");
                    }
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_bag, color: AppColors.darkBlue),
                    onPressed: () {
                      _openAttachmentSelector("Sportswear");
                    }
                  ),
                ],
              ),
              Divider(
                height: 4,
                color: AppColors.textMuted,
                thickness: 1,
              ),
              SizedBox(height: 20)
            ]
          )
        )
      )
    );
  }
}