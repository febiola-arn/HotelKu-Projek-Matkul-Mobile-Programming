import 'package:flutter/material.dart';
import 'dart:async';
import '../models/hotel.dart';
import '../services/api_service.dart';
import '../utils/loading_state.dart';

class HotelProvider with ChangeNotifier {
  // =======================
  // STATE
  // =======================
  List<Hotel> _hotels = [];
  List<Hotel> _filteredHotels = [];
  Hotel? _selectedHotel;

  LoadingState _state = LoadingState.initial;
  String? _error;

  String _searchQuery = '';
  String? _selectedCity;
  double? _minPrice;
  double? _maxPrice;

  Timer? _debounce;

  // =======================
  // GETTERS
  // =======================
  List<Hotel> get hotels => _filteredHotels;
  Hotel? get selectedHotel => _selectedHotel;
  LoadingState get state => _state;
  bool get isLoading => _state.isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCity => _selectedCity;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  // Get unique cities from hotels
  List<String> get cities {
    return _hotels.map((h) => h.city).toSet().toList()..sort();
  }

  // =======================
  // HELPER
  // =======================
  void _applyFilters() {
    _filteredHotels = _hotels.where((hotel) {
      final matchesSearch = _searchQuery.isEmpty ||
          hotel.name.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCity =
          _selectedCity == null || hotel.city == _selectedCity;

      final matchesPrice =
          (_minPrice == null || hotel.pricePerNight >= _minPrice!) &&
          (_maxPrice == null || hotel.pricePerNight <= _maxPrice!);

      return matchesSearch && matchesCity && matchesPrice;
    }).toList();
  }

  // =======================
  // FETCH DATA
  // =======================
  Future<void> fetchHotels({bool refresh = false}) async {
    _state = refresh ? LoadingState.refreshing : LoadingState.loading;
    _error = null;
    notifyListeners();

    try {
      _hotels = await ApiService.getHotels();
      _applyFilters();
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchHotelById(String id) async {
    _state = LoadingState.loading;
    _error = null;
    notifyListeners();

    try {
      _selectedHotel = await ApiService.getHotelById(id);
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    } finally {
      notifyListeners();
    }
  }

  // =======================
  // SEARCH (DEBOUNCE)
  // =======================
  void searchHotels(String query) {
    _searchQuery = query;

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _state = LoadingState.loading;
      notifyListeners();

      try {
        _applyFilters();
        _state = LoadingState.loaded;
      } catch (e) {
        _error = e.toString();
        _state = LoadingState.error;
      } finally {
        notifyListeners();
      }
    });
  }

  // =======================
  // FILTER
  // =======================
  void filterByCity(String? city) {
    _selectedCity = city;
    _state = LoadingState.loading;
    notifyListeners();

    try {
      _applyFilters();
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    } finally {
      notifyListeners();
    }
  }

  void filterByPrice({double? minPrice, double? maxPrice}) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;

    _state = LoadingState.loading;
    notifyListeners();

    try {
      _applyFilters();
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    } finally {
      notifyListeners();
    }
  }

  // =======================
  // UTIL
  // =======================
  void clearFilters() {
    _searchQuery = '';
    _selectedCity = null;
    _minPrice = null;
    _maxPrice = null;

    _applyFilters();
    notifyListeners();
  }

  void setSelectedHotel(Hotel hotel) {
    _selectedHotel = hotel;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // =======================
  // CLEANUP
  // =======================
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
