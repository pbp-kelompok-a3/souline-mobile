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
   return Result(
     id: json["id"] ?? 0,
     authorUsername: json["author_username"]?.toString() ?? "Unknown",
     text: json["text"]?.toString() ?? "",
     image: (json["image"] == null || json["image"].toString().isEmpty) ? null : json["image"].toString(),
     likeCount: json["like_count"] ?? 0,
     likedByUser: json["liked_by_user"] ?? false,
     commentCount: json["comment_count"] ?? 0,
     comments: json["comments"] == null
         ? []
         : List<Comment>.from(json["comments"]!.map((x) => Comment.fromJson(x))),
     // Perbaikan: Pakai created_at (snake_case) sesuai Django
     createdAt: DateTime.parse(json["created_at"] ?? json["createdAt"] ?? DateTime.now().toIso8601String()),
     attachment: json["attachment"],
     isOwner: json["is_owner"] ?? false,
   );
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
   "created_at": createdAt.toIso8601String(),
   "attachment": attachment,
   "is_owner": isOwner,
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
   return Comment(
     id: json["id"] ?? 0,
     authorUsername: json["author_username"]?.toString() ?? "Anonymous",
     content: json["content"]?.toString() ?? "",
     createdAt: DateTime.parse(json["created_at"] ?? json["createdAt"] ?? DateTime.now().toIso8601String()),
   );
 }


 Map<String, dynamic> toJson() => {
   "id": id,
   "author_username": authorUsername,
   "content": content,
   "created_at": createdAt.toIso8601String(),
 };
}