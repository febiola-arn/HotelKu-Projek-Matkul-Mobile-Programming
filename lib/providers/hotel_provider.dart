import 'package:flutter/material.dart';
import 'dart:async';
import '../models/hotel.dart';
import '../services/api_service.dart';
import '../utils/loading_state.dart';

class HotelProvider with ChangeNotifier {
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

  List<Hotel> get hotels => _filteredHotels.isEmpty && _searchQuery.isEmpty && _selectedCity == null
      ? _hotels
      : _filteredHotels;
  Hotel? get selectedHotel => _selectedHotel;
  LoadingState get state => _state;
  bool get isLoading => _state.isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCity => _selectedCity;

  // Get all cities from hotels
  List<String> get cities {
    final citySet = _hotels.map((hotel) => hotel.city).toSet();
    return citySet.toList()..sort();
  }

  // Fetch all hotels
  Future<void> fetchHotels({bool refresh = false}) async {
    _state = refresh ? LoadingState.refreshing : LoadingState.loading;
    _error = null;
    notifyListeners();

    try {
      _hotels = await ApiService.getHotels();
      _filteredHotels = _hotels;
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    } finally {
      notifyListeners();
    }
  }

  // Fetch hotel by ID
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

  // Search hotels with debounce
  void searchHotels(String query) {
    _searchQuery = query;

    // Cancel previous debounce timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      _filteredHotels = _hotels;
      notifyListeners();
      return;
    }

    // Debounce search for 500ms
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _state = LoadingState.loading;
      notifyListeners();

      try {
        _filteredHotels = await ApiService.searchHotels(query);
        _state = LoadingState.loaded;
      } catch (e) {
        _error = e.toString();
        _state = LoadingState.error;
      } finally {
        notifyListeners();
      }
    });
  }

  // Filter by city
  Future<void> filterByCity(String? city) async {
    _selectedCity = city;

    if (city == null) {
      _filteredHotels = _hotels;
      notifyListeners();
      return;
    }

    _state = LoadingState.loading;
    notifyListeners();

    try {
      _filteredHotels = await ApiService.filterHotelsByCity(city);
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    } finally {
      notifyListeners();
    }
  }

  // Filter by price range
  Future<void> filterByPrice({double? minPrice, double? maxPrice}) async {
    _minPrice = minPrice;
    _maxPrice = maxPrice;

    _state = LoadingState.loading;
    notifyListeners();

    try {
      _filteredHotels = await ApiService.filterHotelsByPrice(
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    } finally {
      notifyListeners();
    }
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCity = null;
    _minPrice = null;
    _maxPrice = null;
    _filteredHotels = _hotels;
    notifyListeners();
  }

  // Set selected hotel
  void setSelectedHotel(Hotel hotel) {
    _selectedHotel = hotel;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
