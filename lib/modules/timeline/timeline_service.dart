import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/shared/models/post_entry.dart';
import 'package:souline_mobile/shared/models/resources_entry.dart';
import 'package:souline_mobile/shared/models/sportswear_model.dart';

class TimelineService {
  final CookieRequest request;

  const TimelineService(this.request);

  String _url(String path) => '${AppConstants.baseUrl}$path';

  Future<bool> isAdmin() async {
    try { 
      final data = await request.get(_url('timeline/api/is-admin/'));
      if (data is Map<String, dynamic> && data.containsKey('is_admin')) {
        return data['is_admin'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
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
    Attachment? attachment,
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

  Future<void> editPost(int postId, {
    required String text,
    String? image,
    Attachment? attachment,
  }) async {
    _ensureLoggedIn();

    final payload = {
      'text': text,
      'image': image, 
      'attachment': attachment,
    };

    final res = await request.postJson(
      _url('timeline/api/post/$postId/edit/'), 
      jsonEncode(payload),
    );

    _assertSuccess(res);
  }

  Future<void> toggleLike(int postId) async {
    _ensureLoggedIn();
    
    final res = await request.postJson(
      _url('timeline/api/post/$postId/like/'),
      jsonEncode({}),
    );

    _assertSuccess(res);
  }

  Future<bool> deletePost(int postId) async {
    final url = _url("timeline/api/post/$postId/delete/");

    try {
      final response = await request.postJson(url, null);

      if (response['status'] == 'success') {
        return true;
      } else {
        print("Delete failed: ${response['message']}");
        return false;
      }
    } catch (e) {
      print("Error deleting post: $e");
      return false;
    }
  }

  Future<List<Comment>> fetchComments(int postId) async {
    final response = await request.get(_url('timeline/api/$postId/comments/')); 
    
    List<Comment> list = [];
    for (var d in response) {
      if (d != null) {
        list.add(Comment.fromJson(d));
      }
    }
    return list;
  }

  Future<void> addComment(int postId, String content) async {
    _ensureLoggedIn();

    final payload = {'content': content};

    final res = await request.postJson(
      _url('timeline/api/post/$postId/comment/'),
      jsonEncode(payload),
    );

    _assertSuccess(res);
  }

  Future<bool> deleteComment(int commentId) async {
    final url = "${AppConstants.baseUrl}timeline/api/comment/$commentId/delete/";

    try {
      final response = await request.postJson(url, null);

      if (response['status'] == 'success') {
        return true;
      } else {
        print("Delete failed: ${response['message']}");
        return false;
      }
    } catch (e) {
      print("Error deleting comment: $e");
      return false;
    }
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

  Future<Product> fetchProductById(int id) async {
    final response = await request.get(_url('sportswear/api/list/')); 
    
    List<Product> list = [];
    for (var d in response) {
      if (d != null) {
        list.add(Product.fromJson(d));
      }
    }

    try {
      return list.firstWhere((product) => product.id == id);
    } catch (e) {
      throw Exception("Product with ID $id not found");
    }
  }

  Future<ResourcesEntry> fetchResourceById(int id) async {
    final response = await request.get(_url('resources/api/'));

    List<ResourcesEntry> list = [];
    for (var d in response) {
      if (d != null) {
        list.add(ResourcesEntry.fromJson(d));
      }
    }

    try {
      return list.firstWhere((video) => video.id == id);
    } catch (e) {
      throw Exception("Resource with ID $id not found");
    }
  }
}