import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/api_service.dart';

class ReviewProvider with ChangeNotifier {
  final Map<String, List<Review>> _reviewsByHotel = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get reviews for a specific hotel
  List<Review> getReviewsByHotelId(String hotelId) {
    return _reviewsByHotel[hotelId] ?? [];
  }

  // Get average rating for a hotel
  double getAverageRating(String hotelId) {
    final reviews = getReviewsByHotelId(hotelId);
    if (reviews.isEmpty) return 0.0;
    
    final sum = reviews.fold<double>(0, (prev, review) => prev + review.rating);
    return sum / reviews.length;
  }

  // Fetch reviews by hotel ID
  Future<void> fetchReviewsByHotelId(String hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reviews = await ApiService.getReviewsByHotel(hotelId);
      _reviewsByHotel[hotelId] = reviews;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create review
  Future<bool> createReview(Review review) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newReview = await ApiService.createReview(review.toJson());
      
      // Add review to the list
      if (_reviewsByHotel.containsKey(review.hotelId)) {
        _reviewsByHotel[review.hotelId]!.insert(0, newReview);
      } else {
        _reviewsByHotel[review.hotelId] = [newReview];
      }
      
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

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
