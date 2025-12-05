class Review {
  final String id;
  final String hotelId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.hotelId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });

  // Create Review from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      hotelId: json['hotel_id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'] ?? '',
      userAvatar: json['user_avatar'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert Review to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }
}
