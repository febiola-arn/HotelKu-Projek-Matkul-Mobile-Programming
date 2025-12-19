enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Menunggu Pembayaran';
      case BookingStatus.confirmed:
        return 'Lunas / Dikonfirmasi';
      case BookingStatus.completed:
        return 'Selesai';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

class Booking {
  final String id;
  final String userId;
  final String hotelId;
  final String hotelName;
  final String roomType;
  final DateTime checkIn;
  final DateTime checkOut;
  final int totalNights;
  final double totalPrice;
  final BookingStatus status;
  final DateTime bookingDate;
  final String guestName;
  final String guestPhone;
  final String specialRequest;

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.hotelName,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.totalNights,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
    required this.guestName,
    required this.guestPhone,
    required this.specialRequest,
  });

  // Create Booking from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      hotelId: json['hotel_id'].toString(),
      hotelName: json['hotel_name'] ?? '',
      roomType: json['room_type'] ?? '',
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      totalNights: json['total_nights'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: BookingStatus.fromString(json['status'] ?? 'pending'),
      bookingDate: DateTime.parse(json['booking_date'] ?? DateTime.now().toIso8601String()),
      guestName: json['guest_name'] ?? '',
      guestPhone: json['guest_phone'] ?? '',
      specialRequest: json['special_request'] ?? '',
    );
  }

  // Convert Booking to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hotel_id': hotelId,
      'hotel_name': hotelName,
      'room_type': roomType,
      'check_in': checkIn.toIso8601String().split('T')[0],
      'check_out': checkOut.toIso8601String().split('T')[0],
      'total_nights': totalNights,
      'total_price': totalPrice,
      'status': status.name,
      'booking_date': bookingDate.toIso8601String(),
      'guest_name': guestName,
      'guest_phone': guestPhone,
      'special_request': specialRequest,
    };
  }

  // Calculate total nights
  static int calculateNights(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }

  // Calculate total price
  static double calculateTotalPrice(double pricePerNight, int nights) {
    return pricePerNight * nights;
  }

  // Get formatted price
  String get formattedPrice {
    return 'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  // Copy with
  Booking copyWith({
    String? id,
    String? userId,
    String? hotelId,
    String? hotelName,
    String? roomType,
    DateTime? checkIn,
    DateTime? checkOut,
    int? totalNights,
    double? totalPrice,
    BookingStatus? status,
    DateTime? bookingDate,
    String? guestName,
    String? guestPhone,
    String? specialRequest,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hotelId: hotelId ?? this.hotelId,
      hotelName: hotelName ?? this.hotelName,
      roomType: roomType ?? this.roomType,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      totalNights: totalNights ?? this.totalNights,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      specialRequest: specialRequest ?? this.specialRequest,
    );
  }
}
