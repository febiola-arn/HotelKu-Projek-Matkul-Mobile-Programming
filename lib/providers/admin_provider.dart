import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class AdminProvider with ChangeNotifier {
  List<Booking> _allBookings = [];
  List<Booking> _filteredBookings = [];
  bool _isLoading = false;
  String? _error;

  double _totalRevenue = 0;
  int _activeBookings = 0;
  int _totalFavorites = 0;

  List<Booking> get bookings => _filteredBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalRevenue => _totalRevenue;
  int get activeBookings => _activeBookings;
  int get totalFavorites => _totalFavorites;

  Future<void> fetchBookings(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allBookings = await ApiService.getAdminBookings(userId);
      _filteredBookings = _allBookings;
      await autoCompleteElapsedBookings(userId, silent: true);
      _calculateStats(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateStats(String userId) async {
    double revenue = 0;
    int active = 0;
    for (var b in _allBookings) {
      if (b.status == BookingStatus.confirmed || b.status == BookingStatus.completed) {
        revenue += b.totalPrice;
      }
      if (b.status == BookingStatus.confirmed || b.status == BookingStatus.pending) {
        active++;
      }
    }
    _totalRevenue = revenue;
    _activeBookings = active;

    try {
      final adminHotel = await ApiService.getAdminHotel(userId);
      if (adminHotel != null) {
        _totalFavorites = await ApiService.getFavoriteCount(adminHotel.id);
      }
    } catch (e) {
      _totalFavorites = 0; // Fallback
    }

    notifyListeners();
  }

  Future<void> autoCompleteElapsedBookings(String userId, {bool silent = false}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool anyChanged = false;

    for (int i = 0; i < _allBookings.length; i++) {
      final b = _allBookings[i];
      if (b.status != BookingStatus.confirmed) continue;

      final coDate = DateTime(b.checkOut.year, b.checkOut.month, b.checkOut.day);
      final coNoon = DateTime(b.checkOut.year, b.checkOut.month, b.checkOut.day, 12);

      final shouldComplete = coDate.isBefore(today) || now.isAfter(coNoon);
      if (shouldComplete) {
        try {
          final updated = await ApiService.updateBookingStatus(
            b.id,
            BookingStatus.completed.name,
          );
          _allBookings[i] = updated;
          anyChanged = true;
        } catch (_) {}
      }
    }

    if (anyChanged) {
      _filteredBookings = _allBookings;
      if (!silent) notifyListeners();
    }
  }

  void searchBookings(String query) {
    if (query.isEmpty) {
      _filteredBookings = _allBookings;
    } else {
      _filteredBookings = _allBookings.where((booking) {
        final queryLower = query.toLowerCase();
        return booking.id.toLowerCase().contains(queryLower) ||
               booking.guestName.toLowerCase().contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }
}
