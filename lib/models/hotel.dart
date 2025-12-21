class RoomType {
  final String type;
  final double price;
  final int capacity;
  final int totalRooms;
  final int bookedRooms;
  final int availableRooms;

  RoomType({
    required this.type,
    required this.price,
    required this.capacity,
    this.totalRooms = 0,
    this.bookedRooms = 0,
    this.availableRooms = 0,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    // Baca nilai mentah dari JSON
    final int rawTotalRooms = (json['total_rooms'] ?? 0).toInt();
    final int rawBooked = (json['booked_count'] ?? 0).toInt();
    final int? rawAvailable = json['available_count'] != null
        ? (json['available_count'] ?? 0).toInt()
        : null;

    // Fallback alternatif untuk total rooms jika backend memakai key lain
    int inferredTotal = rawTotalRooms;
    if (inferredTotal <= 0) {
      if (json.containsKey('quantity')) {
        inferredTotal = (json['quantity'] ?? 0).toInt();
      } else if (json.containsKey('units')) {
        inferredTotal = (json['units'] ?? 0).toInt();
      }
    }

    // Jika total_rooms dari server kecil/0 tapi available+booked lebih besar, pakai penjumlahan tsb
    if (rawAvailable != null && (rawAvailable + rawBooked) > inferredTotal) {
      inferredTotal = rawAvailable + rawBooked;
    }

    // Hitung available jika tidak diberikan
    int inferredAvailable = rawAvailable ?? (inferredTotal - rawBooked);
    if (inferredAvailable < 0) inferredAvailable = 0;
    if (inferredAvailable > inferredTotal) inferredAvailable = inferredTotal;

    return RoomType(
      type: json['type'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      capacity: (json['capacity'] ?? 0).toInt(),
      totalRooms: inferredTotal,
      bookedRooms: rawBooked,
      availableRooms: inferredAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'price': price,
      'capacity': capacity,
      'total_rooms': totalRooms,
      'booked_count': bookedRooms,
      'available_count': availableRooms,
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
  final int favoriteCount;
  final int reviewCount;

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
    this.favoriteCount = 0,
    this.reviewCount = 0,
  });

  // Getters for Stats
  int get totalRoomsInventory => roomTypes.fold(0, (sum, item) => sum + item.totalRooms);
  int get totalBookedInventory => roomTypes.fold(0, (sum, item) => sum + item.bookedRooms);
  int get totalAvailableInventory => roomTypes.fold(0, (sum, item) => sum + item.availableRooms);

  // Create Hotel from JSON
  factory Hotel.fromJson(Map<String, dynamic> json) {
    final roomTypesJson = (json['room_types'] as List<dynamic>?) ?? [];
    final roomTypes = roomTypesJson
        .map((e) => RoomType.fromJson(e as Map<String, dynamic>))
        .toList();

    // Calculate minimum price from room types if available
    double pricePerNight = (json['price_per_night'] ?? 0).toDouble();
    if (roomTypes.isNotEmpty) {
      pricePerNight = roomTypes
          .map((e) => e.price)
          .reduce((value, element) => value < element ? value : element);
    }

    return Hotel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      pricePerNight: pricePerNight,
      images: List<String>.from(json['images'] ?? []),
      facilities: List<String>.from(json['facilities'] ?? []),
      roomsAvailable: json['rooms_available'] ?? 0,
      roomTypes: roomTypes,
      favoriteCount: json['favorite_count'] ?? 0,
      reviewCount: json['review_count'] ?? 0,
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
      'favorite_count': favoriteCount,
      'review_count': reviewCount,
    };
  }

  // Get the main image
  String get mainImage => images.isNotEmpty ? images.first : '';

  // Calculate a dynamic rating based on multiple factors
  double get dynamicRating {
    // Base rating is the one from reviews
    double calculatedRating = rating;

    // Add bonus for favorites (e.g., +0.1 for every 10 favorites, max bonus of 0.5)
    double favoriteBonus = (favoriteCount / 10) * 0.1;
    calculatedRating += favoriteBonus > 0.5 ? 0.5 : favoriteBonus;

    // Add bonus for number of reviews (e.g., +0.1 for every 20 reviews, max bonus of 0.5)
    double reviewBonus = (reviewCount / 20) * 0.1;
    calculatedRating += reviewBonus > 0.5 ? 0.5 : reviewBonus;

    // Add bonus for facilities (e.g., +0.05 for each facility, max bonus of 0.5)
    double facilityBonus = facilities.length * 0.05;
    calculatedRating += facilityBonus > 0.5 ? 0.5 : facilityBonus;

    // Ensure rating does not exceed 5.0
    if (calculatedRating > 5.0) {
      return 5.0;
    }

    return calculatedRating;
  }

  // Copy with new values
  Hotel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    double? rating,
    double? pricePerNight,
    List<String>? images,
    List<String>? facilities,
    int? roomsAvailable,
    List<RoomType>? roomTypes,
    int? favoriteCount,
    int? reviewCount,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      images: images ?? this.images,
      facilities: facilities ?? this.facilities,
      roomsAvailable: roomsAvailable ?? this.roomsAvailable,
      roomTypes: roomTypes ?? this.roomTypes,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  // Get formatted price
  String get formattedPrice {
    return 'Rp ${pricePerNight.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}
