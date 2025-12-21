import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserData = 'user_data';

  /// Login user
  static Future<User?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/users/login.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(ApiConstants.timeout);

      final Map<String, dynamic> json = jsonDecode(response.body);
      
      if (response.statusCode == 200 && json['success'] == true) {
        final user = User.fromJson(json['data']);
        await _saveUserData(user);
        return user;
      } else {
        throw Exception(json['message'] ?? 'Login gagal');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Register new user
  static Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? avatar,
    String role = 'customer',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/users/register.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'phone': phone,
              'avatar': avatar ?? 'https://i.pravatar.cc/150?img=${DateTime.now().millisecond % 70}',
              'role': role,
            }),
          )
          .timeout(ApiConstants.timeout);

      final Map<String, dynamic> json = jsonDecode(response.body);
      
      if ((response.statusCode == 200 || response.statusCode == 201) && json['success'] == true) {
        final user = User.fromJson(json['data']);
        await _saveUserData(user);
        return user;
      } else {
        throw Exception(json['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserData);
  }

  /// Get current logged in user
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_keyUserData);
      
      if (userDataString == null) {
        return null;
      }

      final userData = jsonDecode(userDataString);
      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }

  /// Get user profile from API
  static Future<User> getProfile(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/users/profile.php?id=$userId'))
          .timeout(ApiConstants.timeout);

      final Map<String, dynamic> json = jsonDecode(response.body);
      
      if (response.statusCode == 200 && json['success'] == true) {
        return User.fromJson(json['data']);
      } else {
        throw Exception(json['message'] ?? 'Gagal mendapatkan profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Update user profile
  static Future<User> updateProfile(User user) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/users/update_profile.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': user.id,
              'name': user.name,
              'phone': user.phone,
              'avatar': user.avatar,
              'role': user.role,
            }),
          )
          .timeout(ApiConstants.timeout);

      final Map<String, dynamic> json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['success'] == true) {
        final updatedUser = User.fromJson(json['data']);
        final preservedRoleUser = updatedUser.copyWith(role: user.role);
        await _saveUserData(preservedRoleUser);
        return preservedRoleUser;
      } else {
        throw Exception(json['message'] ?? 'Gagal update profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Save user data to SharedPreferences
  static Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserData, jsonEncode(user.toJson()));
  }
}
