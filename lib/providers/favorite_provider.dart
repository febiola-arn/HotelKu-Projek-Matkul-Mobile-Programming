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

  bool isFavorite(String hotelId) {
    return _favorites.any((fav) => fav.hotelId == hotelId);
  }

  Future<void> fetchFavoritesByUserId(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await ApiService.getFavoritesByUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFavorite(String userId, String hotelId) async {
    if (isFavorite(hotelId)) return true;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.addFavorite(userId, hotelId);

      await fetchFavoritesByUserId(userId);


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

  Future<bool> removeFavorite(String userId, String hotelId) async {
    if (!isFavorite(hotelId)) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.removeFavorite(userId, hotelId);
      _favorites.removeWhere((fav) => fav.hotelId == hotelId);

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

  Future<bool> toggleFavorite(String userId, String hotelId) async {
    if (isFavorite(hotelId)) {
      return await removeFavorite(userId, hotelId);
    } else {
      return await addFavorite(userId, hotelId);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
