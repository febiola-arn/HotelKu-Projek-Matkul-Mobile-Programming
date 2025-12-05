import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import '../models/booking.dart';
import '../models/review.dart';
import '../models/favorite.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/exceptions.dart';

class ApiService {
  // Get all hotels
  static Future<List<Hotel>> getHotels() async {
    const endpoint = ApiConstants.hotels;
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}$endpoint'))
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw ApiException.fromResponse(response.statusCode, endpoint);
      }
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Periksa internet Anda');
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } on FormatException {
      throw ApiException('Format data tidak valid');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromError(e);
    }
  }

  // Get hotel by ID
  static Future<Hotel> getHotelById(String id) async {
    final endpoint = '${ApiConstants.hotels}/$id';
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}$endpoint'))
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        return Hotel.fromJson(json.decode(response.body));
      } else {
        throw ApiException.fromResponse(response.statusCode, endpoint);
      }
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Periksa internet Anda');
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromError(e);
    }
  }

  // Search hotels by name or city
  static Future<List<Hotel>> searchHotels(String query) async {
    final endpoint = '${ApiConstants.hotels}?q=$query';
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}$endpoint'))
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw ApiException.fromResponse(response.statusCode, endpoint);
      }
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Periksa internet Anda');
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromError(e);
    }
  }

  // Filter hotels by city
  static Future<List<Hotel>> filterHotelsByCity(String city) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.hotels}?city=$city'))
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to filter hotels');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Filter hotels by price range
  static Future<List<Hotel>> filterHotelsByPrice({
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}${ApiConstants.hotels}?';
      if (minPrice != null) {
        url += 'price_per_night_gte=$minPrice&';
      }
      if (maxPrice != null) {
        url += 'price_per_night_lte=$maxPrice&';
      }

      final response = await http.get(Uri.parse(url)).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to filter hotels');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get reviews by hotel ID
  static Future<List<Review>> getReviewsByHotelId(String hotelId) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}?hotel_id=$hotelId'))
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create booking
  static Future<Booking> createBooking(Booking booking) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookings}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(booking.toJson()),
          )
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 201) {
        return Booking.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get bookings by user ID
  static Future<List<Booking>> getBookingsByUserId(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookings}?user_id=$userId'))
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update booking status
  static Future<Booking> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookings}/$bookingId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'status': status.name}),
          )
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        return Booking.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update booking');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get favorites by user ID
  static Future<List<Favorite>> getFavoritesByUserId(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.favorites}?user_id=$userId'))
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Favorite.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Add to favorites
  static Future<Favorite> addFavorite(String userId, String hotelId) async {
    try {
      final favorite = {
        'user_id': userId,
        'hotel_id': hotelId,
        'added_at': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.favorites}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(favorite),
          )
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 201) {
        return Favorite.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add favorite');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Remove from favorites
  static Future<void> removeFavorite(String favoriteId) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.favorites}/$favoriteId'))
          .timeout(ApiConstants.timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to remove favorite');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create review
  static Future<Review> createReview(Review review) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(review.toJson()),
          )
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 201) {
        return Review.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create review');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get user by ID
  static Future<User> getUserById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.users}/$id'))
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update user
  static Future<User> updateUser(User user) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.users}/${user.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(user.toJson()),
          )
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
