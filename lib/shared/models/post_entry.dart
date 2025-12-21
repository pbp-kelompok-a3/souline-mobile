import 'dart:convert';

Post postFromJson(String str) => Post.fromJson(json.decode(str));

String postToJson(Post data) => json.encode(data.toJson());

class Post {
  List<Result> results;
  dynamic next;
  dynamic previous;

  Post({
    required this.results,
    this.next,
    this.previous,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    results: json["results"] == null 
        ? [] 
        : List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    next: json["next"],
    previous: json["previous"],
  );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
    "next": next,
    "previous": previous,
  };
}

class Result {
  int id;
  String authorUsername;
  String text;
  String? image;   
  int likeCount;
  bool likedByUser;
  int commentCount;
  List<Comment> comments;
  DateTime createdAt;
  Map<String, dynamic>? attachment;
  bool isOwner;

  Result({
    required this.id,
    required this.authorUsername,
    required this.text,
    this.image,
    required this.likeCount,
    required this.likedByUser,
    required this.commentCount,
    required this.comments,
    required this.createdAt,
    this.attachment,
    required this.isOwner,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    try {
      return Result(
        id: json["id"],
        authorUsername: json["author_username"] ?? "Unknown",
        text: json["text"] ?? "",
        image: (json["image"] == null || json["image"] == "") ? null : json["image"], 
        likeCount: json["like_count"] ?? 0,
        likedByUser: json["liked_by_user"] ?? false,
        commentCount: json["comment_count"] ?? 0,
        comments: json["comments"] == null
            ? []
            : List<Comment>.from(json["comments"]!.map((x) => Comment.fromJson(x))),
        createdAt: DateTime.parse(json["createdAt"]),
        attachment: json["attachment"],
        isOwner: json["is_owner"] ?? false,
      );
    } catch (e) {
      print("Error parsing Post ID: ${json['id']}");
      print("JSON Data: $json");
      print("Error Details: $e");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "author_username": authorUsername,
    "text": text,
    "image": image,
    "like_count": likeCount,
    "liked_by_user": likedByUser,
    "comment_count": commentCount,
    "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
    "createdAt": createdAt.toIso8601String(),
    "attachment": attachment,
  };
}

class Comment {
  int id;
  String authorUsername;
  String content;
  DateTime createdAt;

  Comment({
    required this.id,
    required this.authorUsername,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    try {
      return Comment(
        id: json["id"],
        authorUsername: json["author_username"] ?? "Anonymous",
        content: json["content"] ?? "",
        createdAt: DateTime.parse(json["createdAt"]),
      );
    } catch (e) {
      print("Error parsing Comment: $e");
      print("Comment JSON: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "author_username": authorUsername,
    "content": content,
    "createdAt": createdAt.toIso8601String(),
  };
}