import 'dart:convert';

/// Bookmark entry from the API
class BookmarkItem {
  final int id;
  final String contentType;
  final String objectId;
  final String title;
  final DateTime createdAt;

  BookmarkItem({
    required this.id,
    required this.contentType,
    required this.objectId,
    required this.title,
    required this.createdAt,
  });

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return BookmarkItem(
      id: json['id'],
      contentType: json['content_type'],
      objectId: json['object_id'].toString(),
      title: json['title'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content_type': contentType,
    'object_id': objectId,
    'title': title,
    'created_at': createdAt.toIso8601String(),
  };
}

/// Response wrapper for bookmark list API
class BookmarksResponse {
  final String status;
  final List<BookmarkItem> bookmarks;

  BookmarksResponse({required this.status, required this.bookmarks});

  factory BookmarksResponse.fromJson(Map<String, dynamic> json) {
    return BookmarksResponse(
      status: json['status'] ?? '',
      bookmarks:
          (json['bookmarks'] as List<dynamic>?)
              ?.map((e) => BookmarkItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Parses JSON string to BookmarksResponse
BookmarksResponse bookmarksResponseFromJson(String str) =>
    BookmarksResponse.fromJson(json.decode(str));
