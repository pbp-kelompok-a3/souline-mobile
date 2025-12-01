class Post {
  final int id;
  final String username;
  final String text;
  final String? image; // full URL
  final String? resourceTitle;
  final String? resourceThumbnail;
  int likeCount;
  bool likedByUser;
  final int commentCount;


  Post({
    required this.id,
    required this.username,
    required this.text,
    this.image,
    this.resourceTitle,
    this.resourceThumbnail,
    required this.likeCount,
    required this.likedByUser,
    required this.commentCount,
  });


  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
    id: json['id'],
    username: json['author_username'],
    text: json['text'] ?? '',
    image: json['image'],
    resourceTitle: json['resource_title'],
    resourceThumbnail: json['resource_thumbnail'],
    likeCount: json['like_count'] ?? 0,
    likedByUser: json['liked_by_user'] ?? false,
    commentCount: json['comment_count'] ?? 0,
    );
  }
}