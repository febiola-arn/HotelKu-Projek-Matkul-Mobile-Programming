class RoomType {
  final String type;
  final double price;
  final int capacity;

  RoomType({
    required this.type,
    required this.price,
    required this.capacity,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      type: json['type'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      capacity: json['capacity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'price': price,
      'capacity': capacity,
    };
  }
}

class Hotel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final double rating;
  final double pricePerNight;
  final List<String> images;
  final List<String> facilities;
  final int roomsAvailable;
  final List<RoomType> roomTypes;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.rating,
    required this.pricePerNight,
    required this.images,
    required this.facilities,
    required this.roomsAvailable,
    required this.roomTypes,
  });

  // Create Hotel from JSON
  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      pricePerNight: (json['price_per_night'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      facilities: List<String>.from(json['facilities'] ?? []),
      roomsAvailable: json['rooms_available'] ?? 0,
      roomTypes: (json['room_types'] as List<dynamic>?)
              ?.map((e) => RoomType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Convert Hotel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'rating': rating,
      'price_per_night': pricePerNight,
      'images': images,
      'facilities': facilities,
      'rooms_available': roomsAvailable,
      'room_types': roomTypes.map((e) => e.toJson()).toList(),
    };
  }

  // Get the main image
  String get mainImage => images.isNotEmpty ? images.first : '';

  // Get formatted price
  String get formattedPrice {
    return 'Rp ${pricePerNight.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}
