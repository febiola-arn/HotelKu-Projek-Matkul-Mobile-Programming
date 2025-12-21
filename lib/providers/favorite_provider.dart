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

    _error = null;

    final temp = Favorite(
      id: 'temp-$hotelId',
      userId: userId,
      hotelId: hotelId,
      addedAt: DateTime.now(),
    );
    _favorites = [..._favorites, temp];
    notifyListeners();

    try {
      await ApiService.addFavorite(userId, hotelId);
      await fetchFavoritesByUserId(userId);
      return true;
    } catch (e) {
      _favorites.removeWhere((f) => f.hotelId == hotelId);
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFavorite(String userId, String hotelId) async {
    if (!isFavorite(hotelId)) return false;

    _error = null;

    final backup = List<Favorite>.from(_favorites);
    _favorites.removeWhere((f) => f.hotelId == hotelId);
    notifyListeners();

    try {
      await ApiService.removeFavorite(userId, hotelId);
      await fetchFavoritesByUserId(userId);
      return true;
    } catch (e) {
      _favorites = backup;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleFavorite(String userId, String hotelId) async {
    print('Toggling favorite for hotel: $hotelId, current status: ${isFavorite(hotelId)}');
    
    if (isFavorite(hotelId)) {
      final success = await removeFavorite(userId, hotelId);
      print('After remove favorite, status: ${isFavorite(hotelId)}');
      return success;
    } else {
      final success = await addFavorite(userId, hotelId);
      print('After add favorite, status: ${isFavorite(hotelId)}');
      return success;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
