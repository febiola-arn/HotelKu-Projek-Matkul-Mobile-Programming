import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/hotel.dart';
import '../models/user.dart';
import '../models/booking.dart';
import '../models/favorite.dart';
import '../models/review.dart';
import '../utils/constants.dart';

class ApiService {
  // ==================== HOTELS ====================

  static Future<List<Hotel>> getHotels() async {
    final response = await http
        .get(Uri.parse('${ApiConstants.baseUrl}/hotels/'))
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List)
          .map((e) => Hotel.fromJson(e))
          .toList();
    }
    throw Exception(json['message'] ?? 'Failed to get hotels');
  }

  static Future<Hotel> getHotelById(String id) async {
    final response = await http
        .get(Uri.parse('${ApiConstants.baseUrl}/hotels/show.php?id=$id'))
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return Hotel.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Hotel not found');
  }

  static Future<List<Hotel>> searchHotels({
    String? query,
    String? city,
  }) async {
    final params = <String, String>{};

    if (query != null && query.isNotEmpty) params['q'] = query;
    if (city != null && city.isNotEmpty) params['city'] = city;

    final uri = Uri.parse('${ApiConstants.baseUrl}/hotels/search.php')
        .replace(queryParameters: params);

    final response = await http.get(uri).timeout(ApiConstants.timeout);
    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List)
          .map((e) => Hotel.fromJson(e))
          .toList();
    }
    throw Exception(json['message'] ?? 'Search failed');
  }

  // ==================== BOOKINGS ====================

  static Future<List<Booking>> getBookingsByUserId(String userId) async {
    final response = await http
        .get(Uri.parse('${ApiConstants.baseUrl}/bookings/?user_id=$userId'))
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List)
          .map((e) => Booking.fromJson(e))
          .toList();
    }
    throw Exception(json['message'] ?? 'Failed to get bookings');
  }

  static Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    print('DEBUG: Sending booking data: $bookingData');
    print('DEBUG: user_id type: ${bookingData['user_id'].runtimeType}');
    
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/bookings/create.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(bookingData),
        )
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        json['success'] == true) {
      return Booking.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Failed to create booking');
  }

  static Future<Booking> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/bookings/update.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'booking_id': bookingId,
            'status': status,
          }),
        )
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return Booking.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Failed to update booking');
  }

  // ==================== FAVORITES ====================

  static Future<List<Favorite>> getFavoritesByUser(String userId) async {
    final response = await http
        .get(Uri.parse('${ApiConstants.baseUrl}/favorites/?user_id=$userId'))
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List)
          .map((e) => Favorite.fromJson(e))
          .toList();
    }
    throw Exception(json['message'] ?? 'Failed to get favorites');
  }

  static Future<void> addFavorite(String userId, String hotelId) async {
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/favorites/add.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': userId,
            'hotel_id': hotelId,
          }),
        )
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (!(response.statusCode == 200 ||
        response.statusCode == 201 && json['success'] == true)) {
      throw Exception(json['message'] ?? 'Failed to add favorite');
    }
  }

  static Future<void> removeFavorite(String userId, String hotelId) async {
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/favorites/remove.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': userId,
            'hotel_id': hotelId,
          }),
        )
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode != 200 || json['success'] != true) {
      throw Exception(json['message'] ?? 'Failed to remove favorite');
    }
  }

  // ==================== REVIEWS ====================

  static Future<List<Review>> getReviewsByHotel(String hotelId) async {
    final response = await http
        .get(Uri.parse('${ApiConstants.baseUrl}/reviews/?hotel_id=$hotelId'))
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List)
          .map((e) => Review.fromJson(e))
          .toList();
    }
    throw Exception(json['message'] ?? 'Failed to get reviews');
  }

  static Future<Review> createReview(
      Map<String, dynamic> reviewData) async {
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/reviews/create.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(reviewData),
        )
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        json['success'] == true) {
      return Review.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Failed to create review');
  }

  // ==================== ADMIN ====================

  static Future<Hotel?> getAdminHotel(String userId) async {
    final response = await http
        .get(Uri.parse('${ApiConstants.baseUrl}/admin/get_my_hotel.php?user_id=$userId'))
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      if (json['data'] == null) return null;
      return Hotel.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Failed to get admin hotel');
  }

  static Future<bool> updateHotel(Map<String, dynamic> hotelData) async {
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/admin/update_hotel.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(hotelData),
        )
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return true;
    }
    throw Exception(json['message'] ?? 'Failed to update hotel');
  }

  static Future<List<Booking>> getAdminBookings(String userId) async {
    final response = await http
        .get(Uri.parse('${ApiConstants.baseUrl}/admin/get_bookings.php?user_id=$userId'))
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List)
          .map((e) => Booking.fromJson(e))
          .toList();
    }
    throw Exception(json['message'] ?? 'Failed to get admin bookings');
  }

  // ==================== USER ====================

  static Future<User> updateProfile(Map<String, dynamic> updateData) async {
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/users/update_profile.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updateData),
        )
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return User.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Failed to update profile');
  }
}
