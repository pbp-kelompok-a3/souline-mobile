import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/models/resources_entry.dart';

class ResourcesService {
  final CookieRequest request;

  ResourcesService(this.request);

  String _joinBase(String path) {
    final base = AppConstants.baseUrl;
    if (base.endsWith('/')) return '$base$path';
    return '$base/$path';
  }

  void _ensureLoggedIn() {
    if (!request.loggedIn) {
      throw Exception('Anda harus login untuk melakukan aksi ini.');
    }
  }

  Future<ResourcesEntry> create({
    required String title,
    required String description,
    required String youtubeUrl,
    required String level,
  }) async {
    _ensureLoggedIn();

    final payload = {
      'title': title,
      'description': description,
      'youtube_url': youtubeUrl,
      'level': level,
    };

    final response = await request.postJson(
      _joinBase('resources/api/add/'),
      jsonEncode(payload),
    );

    if (response is Map<String, dynamic> && response['status'] == 'success') {
      final id = response['id'];
      return ResourcesEntry(
        id: id is int ? id : int.tryParse(id?.toString() ?? '') ?? 0,
        title: title,
        description: description,
        youtubeUrl: youtubeUrl,
        level: level,
        videoId: '',
        thumbnailUrl: '',
      );
    }

    final msg = response is Map && response['status'] != null
        ? response['status'].toString()
        : 'Unknown error';
    throw Exception('Failed to create resource: $msg');
  }

  Future<void> update({
    required int id,
    required String title,
    required String description,
    required String youtubeUrl,
    required String level,
  }) async {
    _ensureLoggedIn();

    final payload = {
      'title': title,
      'description': description,
      'youtube_url': youtubeUrl,
      'level': level,
    };

    final response = await request.postJson(
      _joinBase('resources/api/edit/$id/'),
      jsonEncode(payload),
    );

    if (response is Map<String, dynamic> &&
        (response['status'] == 'updated' || response['status'] == 'success')) {
      return;
    }

    final msg = response is Map && response['status'] != null
        ? response['status'].toString()
        : 'Unknown error';
    throw Exception('Failed to update resource: $msg');
  }
}
