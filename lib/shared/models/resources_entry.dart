// To parse this JSON data, do
//
//     final resourcesEntry = resourcesEntryFromJson(jsonString);

import 'dart:convert';

List<ResourcesEntry> resourcesEntryFromJson(String str) =>
    List<ResourcesEntry>.from(json.decode(str).map((x) => ResourcesEntry.fromJson(x)));

String resourcesEntryToJson(List<ResourcesEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

String _cleanString(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _extractVideoId(String rawUrl) {
  var url = rawUrl.trim();
  if (url.isEmpty) return '';
  if (!url.contains('://')) {
    url = 'https://$url';
  }
  Uri? uri;
  try {
    uri = Uri.parse(url);
  } catch (_) {
    return '';
  }

  final host = uri.host.toLowerCase();
  if (host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
  }

  if (uri.queryParameters['v']?.isNotEmpty ?? false) {
    return uri.queryParameters['v']!;
  }

  final segments = uri.pathSegments;
  final embedIndex = segments.indexOf('embed');
  if (embedIndex != -1 && embedIndex + 1 < segments.length) {
    return segments[embedIndex + 1];
  }

  return '';
}

String _buildThumbnail(String videoId) {
  if (videoId.isEmpty) return '';
  return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}

class ResourcesEntry {
  int id;
  String title;
  String description;
  String youtubeUrl;
  String videoId;
  String thumbnailUrl;
  String level;

  ResourcesEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.videoId,
    required this.thumbnailUrl,
    required this.level,
  });

  factory ResourcesEntry.fromJson(Map<String, dynamic> json) {
    final rawUrl = _cleanString(json['youtube_url']);
    final rawVideoId = _cleanString(json['video_id']);
    final resolvedVideoId = rawVideoId.isNotEmpty ? rawVideoId : _extractVideoId(rawUrl);
    final rawThumb = _cleanString(json['thumbnail_url']);
    final resolvedThumbnail = rawThumb.isNotEmpty ? rawThumb : _buildThumbnail(resolvedVideoId);

    return ResourcesEntry(
      id: _parseId(json['id']),
      title: _cleanString(json['title']),
      description: _cleanString(json['description']),
      youtubeUrl: rawUrl,
      videoId: resolvedVideoId,
      thumbnailUrl: resolvedThumbnail,
      level: _cleanString(json['level']).toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "youtube_url": youtubeUrl,
        "video_id": videoId,
        "thumbnail_url": thumbnailUrl,
        "level": level,
      };
}
