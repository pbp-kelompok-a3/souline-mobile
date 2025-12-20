import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';

class TimelineService {
  final CookieRequest request;

  const TimelineService(this.request);

  String _url(String path) => '${AppConstants.baseUrl}$path';

  Future<Post> fetchPosts() async {
    final response = await request.get(_url('timeline/api/timeline/'));
    if (response is Map<String, dynamic>) {
       return Post.fromJson(response);
    } else {
       throw Exception('Invalid response format from server');
    }
  }

  Future<void> createPost({
    required String text,
    String? image,
    Map<String, dynamic>? attachment,
  }) async {
    _ensureLoggedIn();

    final payload = {
      'text': text,
      'image': image, 
      'attachment': attachment, 
    };

    final res = await request.postJson(
      _url('timeline/api/create_post/'), 
      jsonEncode(payload),
    );

    _assertSuccess(res);
  }

  Future<void> toggleLike(int postId) async {
    _ensureLoggedIn();
    
    final res = await request.postJson(
      _url('timeline/like_post_flutter/$postId/'),
      jsonEncode({}),
    );

    _assertSuccess(res);
  }

  Future<void> addComment(int postId, String content) async {
    _ensureLoggedIn();

    final payload = {'content': content};

    final res = await request.postJson(
      _url('timeline/add_comment_flutter/$postId/'),
      jsonEncode(payload),
    );

    _assertSuccess(res);
  }

  void _ensureLoggedIn() {
    if (!request.loggedIn) {
      throw Exception('You must be logged in to perform this action.');
    }
  }

  void _assertSuccess(dynamic res) {
    if (res is Map<String, dynamic>) {
      if (res['status'] == 'success' || res['status'] == 'ok') return;
      
      final message = res['message'] ?? 'Unknown error';
      throw Exception('Timeline API error: $message');
    }
    throw Exception('Timeline API error: invalid response format');
  }
}