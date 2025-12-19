// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

Post postFromJson(String str) => Post.fromJson(json.decode(str));

String postToJson(Post data) => json.encode(data.toJson());

class Post {
    List<Result> results;
    dynamic next;
    dynamic previous;

    Post({
        required this.results,
        required this.next,
        required this.previous,
    });

    factory Post.fromJson(Map<String, dynamic> json) => Post(
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
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
    dynamic image;
    dynamic resourceTitle;
    dynamic resourceThumbnail;
    dynamic sportswearTitle;
    dynamic sportswearThumbnail;
    int likeCount;
    bool likedByUser;
    int commentCount;
    List<Comment> comments;
    DateTime created_at;
    Map<String, dynamic>? attachment;

    Result({
        required this.id,
        required this.authorUsername,
        required this.text,
        this.image,
        this.resourceTitle,
        this.resourceThumbnail,
        this.sportswearTitle,
        this.sportswearThumbnail,
        required this.likeCount,
        required this.likedByUser,
        required this.commentCount,
        required this.comments,
        required this.created_at,
        this.attachment,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        authorUsername: json["author_username"],
        text: json["text"],
        image: json["image"],
        resourceTitle: json["resource_title"],
        resourceThumbnail: json["resource_thumbnail"],
        sportswearTitle: json["sportswear_title"],
        sportswearThumbnail: json["sportswear_thumbnail"],
        likeCount: json["like_count"],
        likedByUser: json["liked_by_user"],
        commentCount: json["comment_count"],
        comments: List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))),
        created_at: DateTime.parse(json["created_at"]),
        attachment: json['attachment']
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "author_username": authorUsername,
        "text": text,
        "image": image,
        "resource_title": resourceTitle,
        "resource_thumbnail": resourceThumbnail,
        "sportswear_title": sportswearTitle,
        "sportswear_thumbnail": sportswearThumbnail,
        "like_count": likeCount,
        "liked_by_user": likedByUser,
        "comment_count": commentCount,
        "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
        "created_at": created_at,
        "attachment": attachment,
    };
}

class Comment {
    int id;
    int postId;
    String authorUsername;
    String content;
    DateTime createdAt;

    Comment({
        required this.id,
        required this.postId,
        required this.authorUsername,
        required this.content,
        required this.createdAt,
    });

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"],
        postId: json["post"],
        authorUsername: json["author_username"],
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "postId": postId,
        "author_username": authorUsername,
        "content": content,
        "created_at": createdAt.toIso8601String(),
    };
}