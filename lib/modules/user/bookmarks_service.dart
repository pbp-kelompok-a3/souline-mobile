import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/models/bookmark_item.dart';

/// Content type constants (model names)
class BookmarkContentType {
  static const String studio = 'studio';
  static const String event = 'event';
  static const String resource = 'resource';
  static const String sportswear = 'sportswearbrand';
  static const String post = 'post';
}

/// App label constants (app names)
class BookmarkAppLabel {
  static const String studio = 'studio';
  static const String events = 'events';
  static const String resources = 'resources';
  static const String sportswear = 'sportswear';
  static const String timeline = 'timeline';
}

/// Service for managing bookmarks
class BookmarksService {
  final CookieRequest request;

  // Cache of bookmarks for quick lookups
  List<BookmarkItem> _cachedBookmarks = [];
  bool _isCacheValid = false;

  BookmarksService(this.request);

  // Base URL for API calls
  String get _baseUrl => AppConstants.baseUrl;

  // Build full URL from path
  String _buildUrl(String path) {
    if (_baseUrl.endsWith('/')) return '$_baseUrl$path';
    return '$_baseUrl/$path';
  }

  /// Fetch all bookmarks for the current user.
  /// Caches results for quick isBookmarked lookups.
  Future<List<BookmarkItem>> fetchBookmarks() async {
    try {
      final response = await request.get(_buildUrl('bookmarks/list/'));

      if (response['status'] == 'success') {
        final bookmarks =
            (response['bookmarks'] as List<dynamic>?)
                ?.map((e) => BookmarkItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        _cachedBookmarks = bookmarks;
        _isCacheValid = true;

        return bookmarks;
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching bookmarks: $e');
      return [];
    }
  }

  /// Add a bookmark for the given item.
  Future<bool> addBookmark({
    required String appLabel,
    required String model,
    required String objectId,
  }) async {
    try {
      final response = await request.postJson(
        _buildUrl('bookmarks/add/'),
        jsonEncode({'app_label': appLabel, 'model': model, 'id': objectId}),
      );

      if (response['status'] == 'success') {
        _isCacheValid = false; // Invalidate cache
        return true;
      }

      debugPrint('Add bookmark failed: ${response['message']}');
      return false;
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
      return false;
    }
  }

  /// Remove a bookmark by its bookmark ID.
  Future<bool> removeBookmark(int bookmarkId) async {
    try {
      final response = await request.postJson(
        _buildUrl('bookmarks/remove/$bookmarkId/'),
        jsonEncode({}),
      );

      if (response['status'] == 'success') {
        _isCacheValid = false; // Invalidate cache
        return true;
      }

      debugPrint('Remove bookmark failed: ${response['message']}');
      return false;
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
      return false;
    }
  }

  /// Remove a bookmark by object reference.
  Future<bool> removeBookmarkByObject({
    required String appLabel,
    required String model,
    required String objectId,
  }) async {
    try {
      final response = await request.postJson(
        _buildUrl('bookmarks/remove/'),
        jsonEncode({'app_label': appLabel, 'model': model, 'id': objectId}),
      );

      if (response['status'] == 'success') {
        _isCacheValid = false;
        return true;
      }

      debugPrint('Remove bookmark by object failed: ${response['message']}');
      return false;
    } catch (e) {
      debugPrint('Error removing bookmark by object: $e');
      return false;
    }
  }

  /// Check if an item is bookmarked.
  Future<bool> isBookmarked(String contentType, String objectId) async {
    if (!_isCacheValid) {
      await fetchBookmarks();
    }

    return _cachedBookmarks.any(
      (b) => b.contentType == contentType && b.objectId == objectId,
    );
  }

  /// Get bookmark ID for an item (for removal)
  int? getBookmarkId(String contentType, String objectId) {
    final bookmark = _cachedBookmarks.firstWhere(
      (b) => b.contentType == contentType && b.objectId == objectId,
      orElse: () => BookmarkItem(
        id: -1,
        contentType: '',
        objectId: '',
        title: '',
        createdAt: DateTime.now(),
      ),
    );

    return bookmark.id >= 0 ? bookmark.id : null;
  }

  /// Toggle bookmark state for an item
  Future<bool> toggleBookmark({
    required String appLabel,
    required String model,
    required String objectId,
  }) async {
    final contentType = model;
    final isCurrentlyBookmarked = await isBookmarked(contentType, objectId);

    if (isCurrentlyBookmarked) {
      final bookmarkId = getBookmarkId(contentType, objectId);
      if (bookmarkId != null) {
        final success = await removeBookmark(bookmarkId);
        return !success; // If removal succeeded, it's no longer bookmarked
      } else {
        // Fallback to remove by object
        final success = await removeBookmarkByObject(
          appLabel: appLabel,
          model: model,
          objectId: objectId,
        );
        return !success;
      }
    } else {
      final success = await addBookmark(
        appLabel: appLabel,
        model: model,
        objectId: objectId,
      );
      return success; // If add succeeded, it's now bookmarked
    }
  }

  /// Invalidate cache to force fresh fetch
  void invalidateCache() {
    _isCacheValid = false;
    _cachedBookmarks = [];
  }

  /// Get bookmarks filtered by content type
  List<BookmarkItem> getBookmarksByType(String contentType) {
    return _cachedBookmarks.where((b) => b.contentType == contentType).toList();
  }
}
