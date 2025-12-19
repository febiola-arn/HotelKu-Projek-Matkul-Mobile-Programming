import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get bookings by status
  List<Booking> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  // Get upcoming bookings
  List<Booking> get upcomingBookings {
    final now = DateTime.now();
    return _bookings
        .where((booking) =>
            (booking.status == BookingStatus.pending ||
                booking.status == BookingStatus.confirmed) &&
            booking.checkIn.isAfter(now))
        .toList();
  }

  // Get completed bookings
  List<Booking> get completedBookings {
    return _bookings
        .where((booking) => booking.status == BookingStatus.completed)
        .toList();
  }

  // Get cancelled bookings
  List<Booking> get cancelledBookings {
    return _bookings
        .where((booking) => booking.status == BookingStatus.cancelled)
        .toList();
  }

  // Fetch bookings by user ID
  Future<void> fetchBookingsByUserId(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await ApiService.getBookingsByUserId(userId);
      // Sort by booking date (newest first)
      _bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create booking
  Future<bool> createBooking(Booking booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newBooking = await ApiService.createBooking(booking.toJson());
      _bookings.insert(0, newBooking);
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

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, BookingStatus status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedBooking = await ApiService.updateBookingStatus(bookingId, status.name);
      
      // Update booking in list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updatedBooking;
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

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
