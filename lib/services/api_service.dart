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
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/hotels/'),
      headers: {
        'ngrok-skip-browser-warning': '1',
        'Accept': 'application/json',
      },
    ).timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List)
          .map((e) => Hotel.fromJson(e))
          .toList();
    }
    throw Exception(json['message'] ?? 'Failed to get hotels');
  }

  static Future<Hotel> getHotelById(String id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/hotels/show.php?id=$id'),
      headers: {
        'ngrok-skip-browser-warning': '1',
        'Accept': 'application/json',
      },
    ).timeout(ApiConstants.timeout);

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

    final response = await http.get(
      uri,
      headers: {
        'ngrok-skip-browser-warning': '1',
        'Accept': 'application/json',
      },
    ).timeout(ApiConstants.timeout);
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
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/bookings/?user_id=$userId'),
      headers: {
        'ngrok-skip-browser-warning': '1',
        'Accept': 'application/json',
      },
    ).timeout(ApiConstants.timeout);

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
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1',
            'Accept': 'application/json',
          },
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
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1',
            'Accept': 'application/json',
          },
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
    // Attempt 1: directory index path
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/favorites/?user_id=$userId'),
        headers: {
          'ngrok-skip-browser-warning': '1',
          'Accept': 'application/json',
        },
      ).timeout(ApiConstants.timeout);

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['success'] == true) {
        return (json['data'] as List)
            .map((e) => Favorite.fromJson(e))
            .toList();
      }
    } catch (_) {
      // ignore and try explicit file path
    }

    // Attempt 2: explicit index.php path (more robust across servers)
    final response2 = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/favorites/index.php?user_id=$userId'),
      headers: {
        'ngrok-skip-browser-warning': '1',
        'Accept': 'application/json',
      },
    ).timeout(ApiConstants.timeout);

    final json2 = jsonDecode(response2.body);

    if (response2.statusCode == 200 && json2['success'] == true) {
      return (json2['data'] as List)
          .map((e) => Favorite.fromJson(e))
          .toList();
    }
    throw Exception(json2['message'] ?? 'Failed to get favorites');
  }

  static Future<void> addFavorite(String userId, String hotelId) async {
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/favorites/add.php'),
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'user_id': userId,
            'hotel_id': hotelId,
          }),
        )
        .timeout(ApiConstants.timeout);

    Map<String, dynamic>? json;
    String message = '';
    bool success = false;
    final int status = response.statusCode;

    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
      message = (json['message'] ?? '').toString();
      success = json['success'] == true || json['success'] == 1 ||
          (json['success'] is String &&
              ((json['success'] as String).toLowerCase() == 'true' || json['success'] == '1'));
    } catch (_) {
      // Non-JSON response: rely on HTTP status only
      if (status == 200 || status == 201) return;
    }

    if ((status == 200 || status == 201) && success) return;
    if (status == 400 && message.toLowerCase().contains('sudah ada')) return;
    if (status == 409) return; // conflict -> already exists

    throw Exception(message.isNotEmpty ? message : 'Failed to add favorite');
  }

  static Future<void> removeFavorite(String userId, String hotelId) async {
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/favorites/remove.php'),
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'user_id': userId,
            'hotel_id': hotelId,
          }),
        )
        .timeout(ApiConstants.timeout);

    Map<String, dynamic>? json;
    String message = '';
    bool success = false;
    final int status = response.statusCode;

    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
      message = (json['message'] ?? '').toString();
      success = json['success'] == true || json['success'] == 1 ||
          (json['success'] is String &&
              ((json['success'] as String).toLowerCase() == 'true' || json['success'] == '1'));
    } catch (_) {
      // Non-JSON response: if 200, treat as success; if 404 treat as idempotent success
      if (status == 200 || status == 404) return;
    }

    if (status == 200 && success) return;
    if (status == 404) return; // already removed

    throw Exception(message.isNotEmpty ? message : 'Failed to remove favorite');
  }

  static Future<Map<String, dynamic>> getFavoriteStats(String hotelId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/favorites/stats.php?hotel_id=$hotelId'),
      headers: {
        'ngrok-skip-browser-warning': '1',
        'Accept': 'application/json',
      },
    ).timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return json['data'] as Map<String, dynamic>;
    }
    throw Exception(json['message'] ?? 'Failed to get favorite stats');
  }

  // ==================== REVIEWS ====================

  static Future<List<Review>> getReviewsByHotel(String hotelId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/reviews/?hotel_id=$hotelId'),
      headers: {
        'ngrok-skip-browser-warning': '1',
        'Accept': 'application/json',
      },
    ).timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List)
          .map((e) => Review.fromJson(e))
          .toList();
    }
    throw Exception(json['message'] ?? 'Failed to get reviews');
  }

  static Future<Review> createReview(Map<String, dynamic> reviewData) async {
    // Normalize payload to strings for maximum backend compatibility
    final bool isAnonymous = reviewData['anonymous'] == true || reviewData['is_anonymous'] == true;
    final payload = <String, String>{
      'hotel_id': (reviewData['hotel_id'] ?? '').toString(),
      'user_id' : (reviewData['user_id'] ?? '').toString(),
      'rating'  : (reviewData['rating'] ?? '').toString(),
      'comment' : (reviewData['comment'] ?? '').toString(),
      // Optional identity fields for display
      if (!isAnonymous) 'user_name': (reviewData['user_name'] ?? '').toString(),
      if (!isAnonymous) 'user_avatar': (reviewData['user_avatar'] ?? '').toString(),
      // Backend-friendly flag
      'anonymous': isAnonymous.toString(),
    };

    Future<Review> _handleResponse(http.Response response) async {
      Map<String, dynamic>? json;
      String message = '';
      bool success = false;
      try {
        json = jsonDecode(response.body) as Map<String, dynamic>;
        message = (json['message'] ?? '').toString();
        success = json['success'] == true || json['success'] == 1 ||
            (json['success'] is String &&
                ((json['success'] as String).toLowerCase() == 'true' || json['success'] == '1'));
      } catch (_) {
        // Non-JSON response: rely on HTTP status only
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Create a minimal Review object from the payload
          return Review(
            id: '0',
            hotelId: payload['hotel_id'] ?? '',
            userId: payload['user_id'] ?? '',
            userName: (payload['anonymous'] == 'true')
                ? 'Anonim'
                : (payload['user_name'] ?? ''),
            userAvatar: (payload['anonymous'] == 'true')
                ? ''
                : (payload['user_avatar'] ?? ''),
            rating: double.tryParse(payload['rating'] ?? '0') ?? 0,
            comment: payload['comment'] ?? '',
            date: DateTime.now(),
          );
        }
      }

      if ((response.statusCode == 200 || response.statusCode == 201) && success) {
        final data = json?['data'];
        if (data is Map<String, dynamic>) {
          return Review.fromJson(data);
        }
        // If backend doesn't return data, synthesize minimal review
        return Review(
          id: (json?['id'] ?? '0').toString(),
          hotelId: payload['hotel_id'] ?? '',
          userId: payload['user_id'] ?? '',
          userName: (payload['anonymous'] == 'true')
              ? 'Anonim'
              : (payload['user_name'] ?? ''),
          userAvatar: (payload['anonymous'] == 'true')
              ? ''
              : (payload['user_avatar'] ?? ''),
          rating: double.tryParse(payload['rating'] ?? '0') ?? 0,
          comment: payload['comment'] ?? '',
          date: DateTime.now(),
        );
      }

      // Duplicate scenarios should surface as an error so UI can inform the user properly
      final lower = message.toLowerCase();
      if (response.statusCode == 409 || lower.contains('sudah ada') || lower.contains('duplicate')) {
        throw Exception(message.isNotEmpty ? message : 'Anda sudah pernah mengulas hotel ini');
      }

      throw Exception(message.isNotEmpty ? message : 'Failed to create review');
    }

    // Attempt 1: JSON body
    try {
      final respJson = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/reviews/create.php'),
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': '1',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(ApiConstants.timeout);
      return await _handleResponse(respJson);
    } catch (_) {
      // ignore and try form-encoded below
    }

    // Attempt 2: form-encoded body (for PHP endpoints expecting $_POST)
    final respForm = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/reviews/create.php'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'ngrok-skip-browser-warning': '1',
            'Accept': 'application/json',
          },
          body: payload,
        )
        .timeout(ApiConstants.timeout);

    return await _handleResponse(respForm);
  }

  // ==================== STATS ====================

  static Future<int> getFavoriteCount(String hotelId) async {
    // Try standardized stats endpoint first to keep Admin & Customer consistent
    try {
      final responseStats = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/favorites/stats.php?hotel_id=$hotelId'),
        headers: {
          'ngrok-skip-browser-warning': '1',
          'Accept': 'application/json',
        },
      ).timeout(ApiConstants.timeout);

      final jsonStats = jsonDecode(responseStats.body);
      if (responseStats.statusCode == 200 && jsonStats['success'] == true) {
        final dynamic raw = (jsonStats['data'] is Map)
            ? (jsonStats['data']['count'])
            : null;
        if (raw is int) return raw;
        if (raw is num) return raw.toInt();
        if (raw is String) return int.tryParse(raw) ?? 0;
      }
    } catch (_) {}

    // Fallback: count endpoint
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/favorites/count.php?hotel_id=$hotelId'),
        headers: {
          'ngrok-skip-browser-warning': '1',
          'Accept': 'application/json',
        },
      ).timeout(ApiConstants.timeout);

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['success'] == true) {
        final dynamic raw = (json['data'] is Map)
            ? (json['data']['count'])
            : null;
        if (raw is int) return raw;
        if (raw is num) return raw.toInt();
        if (raw is String) return int.tryParse(raw) ?? 0;
      }
    } catch (_) {}

    // Fallback: fetch hotel details and read favorite_count if provided by backend
    try {
      final response2 = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/hotels/show.php?id=$hotelId'),
        headers: {
          'ngrok-skip-browser-warning': '1',
          'Accept': 'application/json',
        },
      ).timeout(ApiConstants.timeout);

      final json2 = jsonDecode(response2.body);
      if (response2.statusCode == 200 && json2['success'] == true) {
        final dynamic fav = json2['data']?['favorite_count'];
        if (fav is int) return fav;
        if (fav is num) return fav.toInt();
        if (fav is String) return int.tryParse(fav) ?? 0;
      }
    } catch (_) {
      // ignore
    }

    // Default when all attempts fail
    return 0;
  }

  static Future<int> getReviewCount(String hotelId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/reviews/count.php?hotel_id=$hotelId'),
      headers: {
        'ngrok-skip-browser-warning': '1',
        'Accept': 'application/json',
      },
    ).timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return (json['data']['count'] as int?) ?? 0;
    }
    // Don't throw exception, just return 0 if it fails
    return 0;
  }

  // ==================== ADMIN ====================

  static Future<Hotel?> getAdminHotel(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/get_my_hotel.php?user_id=$userId'),
      headers: {
        'ngrok-skip-browser-warning': '1',
        'Accept': 'application/json',
      },
    ).timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      if (json['data'] == null) return null;
      return Hotel.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Failed to get admin hotel');
  }

  static Future<bool> updateHotel(Map<String, dynamic> hotelData) async {
    // Normalisasi payload agar backend apapun yang mengharapkan key berbeda tetap menerima jumlah unit kamar.
    // Beberapa backend menggunakan 'total_rooms', sebagian lain 'quantity' atau 'units'.
    final normalized = Map<String, dynamic>.from(hotelData);
    if (normalized['room_types'] is List) {
      final List roomTypes = normalized['room_types'] as List;
      normalized['room_types'] = roomTypes.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        final dynamic rawTotal = m['total_rooms'] ?? m['quantity'] ?? m['units'] ?? 0;
        int totalInt;
        if (rawTotal is String) {
          totalInt = int.tryParse(rawTotal) ?? 0;
        } else if (rawTotal is num) {
          totalInt = rawTotal.toInt();
        } else {
          totalInt = 0;
        }

        // Pastikan tiga key ini selalu sinkron sebagai JUMLAH UNIT kamar.
        m['total_rooms'] = totalInt;
        m['quantity'] = totalInt;
        m['units'] = totalInt;
        return m;
      }).toList();
    }

    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/admin/update_hotel.php'),
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1',
            'Accept': 'application/json',
          },
          body: jsonEncode(normalized),
        )
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['success'] == true) {
      return true;
    }
    throw Exception(json['message'] ?? 'Failed to update hotel');
  }

  // ==================== INVENTORY ====================
  static Future<void> updateRoomInventory({
    required String hotelId,
    required String roomType,
    required int deltaBooked,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/admin/update_room_inventory.php'),
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'hotel_id': hotelId,
            'room_type': roomType,
            'delta_booked': deltaBooked,
          }),
        )
        .timeout(ApiConstants.timeout);

    final json = jsonDecode(response.body);

    if (!(response.statusCode == 200 && json['success'] == true)) {
      throw Exception(json['message'] ?? 'Failed to update room inventory');
    }
  }

  static Future<List<Booking>> getAdminBookings(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/get_bookings.php?user_id=$userId'),
      headers: {
        'ngrok-skip-browser-warning': '1',
        'Accept': 'application/json',
      },
    ).timeout(ApiConstants.timeout);

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
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1',
            'Accept': 'application/json',
          },
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
