import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserData = 'user_data';

  // Login
  static Future<User?> login(String email, String password) async {
    try {
      // Query users with email and password
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.users}?email=$email&password=$password'))
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isEmpty) {
          throw Exception('Email atau password salah');
        }

        final user = User.fromJson(data.first);
        
        // Save user data to SharedPreferences
        await _saveUserData(user);
        
        return user;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Register
  static Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? avatar,
  }) async {
    try {
      // Check if email already exists
      final checkResponse = await http
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.users}?email=$email'))
          .timeout(ApiConstants.timeout);

      if (checkResponse.statusCode == 200) {
        final List<dynamic> existingUsers = json.decode(checkResponse.body);
        if (existingUsers.isNotEmpty) {
          throw Exception('Email sudah terdaftar');
        }
      }

      // Create new user
      final newUser = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'avatar': avatar ?? 'https://i.pravatar.cc/150?img=${DateTime.now().millisecond % 70}',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.users}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(newUser),
          )
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 201) {
        final user = User.fromJson(json.decode(response.body));
        
        // Save user data to SharedPreferences
        await _saveUserData(user);
        
        return user;
      } else {
        throw Exception('Failed to register');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserData);
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_keyUserData);
      
      if (userDataString == null) {
        return null;
      }

      final userData = json.decode(userDataString);
      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }

  // Update profile
  static Future<User> updateProfile(User user) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.users}/${user.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(user.toJson()),
          )
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(json.decode(response.body));
        
        // Update user data in SharedPreferences
        await _saveUserData(updatedUser);
        
        return updatedUser;
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Save user data to SharedPreferences
  static Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserData, json.encode(user.toJson()));
  }
}
