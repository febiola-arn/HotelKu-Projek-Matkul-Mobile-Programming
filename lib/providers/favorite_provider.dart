import 'package:flutter/material.dart';
import '../models/favorite.dart';
import '../services/api_service.dart';

class FavoriteProvider with ChangeNotifier {
  List<Favorite> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<Favorite> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Check if hotel is favorited
  bool isFavorite(String hotelId) {
    return _favorites.any((fav) => fav.hotelId == hotelId);
  }

  // Get favorite ID by hotel ID
  String? getFavoriteId(String hotelId) {
    try {
      return _favorites.firstWhere((fav) => fav.hotelId == hotelId).id;
    } catch (e) {
      return null;
    }
  }

  // Fetch favorites by user ID
  Future<void> fetchFavoritesByUserId(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await ApiService.getFavoritesByUserId(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to favorites
  Future<bool> addFavorite(String userId, String hotelId) async {
    // Check if already favorited
    if (isFavorite(hotelId)) {
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final favorite = await ApiService.addFavorite(userId, hotelId);
      _favorites.add(favorite);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Remove from favorites
  Future<bool> removeFavorite(String hotelId) async {
    final favoriteId = getFavoriteId(hotelId);
    
    if (favoriteId == null) {
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.removeFavorite(favoriteId);
      _favorites.removeWhere((fav) => fav.id == favoriteId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle favorite
  Future<bool> toggleFavorite(String userId, String hotelId) async {
    if (isFavorite(hotelId)) {
      return await removeFavorite(hotelId);
    } else {
      return await addFavorite(userId, hotelId);
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
