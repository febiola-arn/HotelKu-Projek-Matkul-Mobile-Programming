class Favorite {
  final String id;
  final String userId;
  final String hotelId;
  final DateTime addedAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.addedAt,
  });

  // Create Favorite from JSON
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      hotelId: json['hotel_id'].toString(),
      addedAt: DateTime.parse(json['added_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert Favorite to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hotel_id': hotelId,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
