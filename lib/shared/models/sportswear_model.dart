class Review {
  final String username;
  final String location;
  final String reviewText;
  final double ratingValue;

  Review({
    required this.username,
    required this.location,
    required this.reviewText,
    required this.ratingValue,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      // Sesuaikan key dengan JSON Django: 'review_text' dan 'rating_value'
      username: (json['username'] ?? 'Unknown').toString(),
      location: (json['location'] ?? 'N/A').toString(),
      reviewText: (json['review_text'] ?? 'No review text.').toString(),
      ratingValue: (json['rating_value'] as num? ?? 0.0).toDouble(),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final String tag;
  final String thumbnail;
  final double rating;
  final String link;
  final List<Review> timelineReviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.tag,
    required this.thumbnail,
    required this.rating,
    required this.link,
    required this.timelineReviews,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: (json['name'] ?? 'N/A').toString(),
      description: (json['description'] ?? '').toString(),
      tag: (json['tag'] ?? 'Uncategorized').toString(),
      thumbnail: (json['thumbnail'] ?? '').toString(),
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      link: (json['link'] ?? '').toString(),
      // Ambil dari key 'reviews' sesuai JSON yang kamu kirim tadi
      timelineReviews: (json['reviews'] as List? ?? [])
          .map((i) => Review.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tag': tag,
      'thumbnail': thumbnail,
      'rating': rating,
      'link': link,
      // Tambahin ini kalau perlu simpan reviews juga
      'reviews': timelineReviews.map((v) => {
        'username': v.username,
        'location': v.location,
        'review_text': v.reviewText,
        'rating_value': v.ratingValue,
      }).toList(),
    };
  }
}