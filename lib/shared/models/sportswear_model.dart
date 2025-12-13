
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

  // Constructor untuk parsing JSON dari Django
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      username: json['username'] ?? 'Unknown',
      location: json['location'] ?? 'N/A',
      reviewText: json['review_text'] ?? 'No review text.',
      ratingValue: (json['rating_value'] as num).toDouble(),
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
  final String? adminNotes;
  final List<Review> timelineReviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.tag,
    required this.thumbnail,
    required this.rating,
    required this.link,
    this.adminNotes,
    required this.timelineReviews,
  });

  // Constructor untuk parsing JSON dari Django
  factory Product.fromJson(Map<String, dynamic> json) {
    var reviewsList = json['reviews'] as List? ?? [];
    List<Review> reviews = reviewsList.map((i) => Review.fromJson(i as Map<String, dynamic>)).toList();

    return Product(
      id: json['id'] ?? 0,
      // Mengambil data dari key yang sesuai dengan serialisasi Django
      name: json['name'] ?? 'N/A',
      description: json['description'] ?? 'No description.',
      tag: json['tag'] ?? 'Uncategorized',
      thumbnail: json['thumbnail'] ?? 'https://via.placeholder.com/150',
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      link: json['link'] ?? 'http://example.com',
      adminNotes: json['admin_notes'],
      timelineReviews: reviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // POST/PUT payload harus sesuai dengan field di SportswearBrandForm Django
      'brand_name': name,
      'description': description,
      'category_tag': tag,
      'thumbnail_url': thumbnail,
      'average_rating': rating,
      'link': link,
    };
  }
}