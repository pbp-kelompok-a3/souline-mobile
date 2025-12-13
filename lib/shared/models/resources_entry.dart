// To parse this JSON data, do
//
//     final resourcesEntry = resourcesEntryFromJson(jsonString);

import 'dart:convert';

List<ResourcesEntry> resourcesEntryFromJson(String str) => List<ResourcesEntry>.from(json.decode(str).map((x) => ResourcesEntry.fromJson(x)));

String resourcesEntryToJson(List<ResourcesEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

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

    factory ResourcesEntry.fromJson(Map<String, dynamic> json) => ResourcesEntry(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        youtubeUrl: json["youtube_url"],
        videoId: json["video_id"],
        thumbnailUrl: json["thumbnail_url"],
        level: json["level"],
    );

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
