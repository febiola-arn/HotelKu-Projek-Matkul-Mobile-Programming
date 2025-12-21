import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

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
      await autoCompleteElapsedBookings(silent: true);
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
      final current = await AuthService.getCurrentUser();
      final role = (current?.role ?? '').toLowerCase();
      if (role == 'admin' || role == 'hotel_admin' || role == 'owner') {
        _error = 'Admin tidak dapat melakukan booking.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newBooking = await ApiService.createBooking(booking.toJson());
      _bookings.insert(0, newBooking);
      try {
        await ApiService.updateRoomInventory(
          hotelId: booking.hotelId,
          roomType: booking.roomType,
          deltaBooked: 1,
        );
      } catch (_) {}
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
      BookingStatus? prevStatus;
      Booking? prevBooking;
      final idxBefore = _bookings.indexWhere((b) => b.id == bookingId);
      if (idxBefore != -1) {
        prevStatus = _bookings[idxBefore].status;
        prevBooking = _bookings[idxBefore];
      }

      final updatedBooking = await ApiService.updateBookingStatus(bookingId, status.name);
      
      // Update booking in list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updatedBooking;
      }
      if (updatedBooking.status == BookingStatus.cancelled && prevStatus != BookingStatus.cancelled && prevBooking != null) {
        try {
          await ApiService.updateRoomInventory(
            hotelId: prevBooking.hotelId,
            roomType: prevBooking.roomType,
            deltaBooked: -1,
          );
        } catch (_) {}
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

  Future<void> autoCompleteElapsedBookings({bool silent = false}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noonToday = DateTime(today.year, today.month, today.day, 12);
    bool anyChanged = false;

    for (int i = 0; i < _bookings.length; i++) {
      final b = _bookings[i];
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
          _bookings[i] = updated;
          anyChanged = true;
        } catch (_) {}
      }
    }

    if (!silent && anyChanged) {
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
