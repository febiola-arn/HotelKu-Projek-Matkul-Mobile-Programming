import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/hotel_card.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../hotel/hotel_detail_page.dart';
import '../../models/hotel.dart';
import '../../services/api_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Hotel> _favoriteHotels = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoriteHotels();
    });
  }

  Future<void> _loadFavoriteHotels() async {
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Load favorites data
      await favoriteProvider.fetchFavoritesByUserId(authProvider.currentUser!.id);
      
      // Get favorite hotel IDs
      final favoriteIds = favoriteProvider.favorites.map((f) => f.hotelId).toSet();
      
      // Fetch hotel details for each favorite
      List<Hotel> hotels = [];
      for (String hotelId in favoriteIds) {
        try {
          final hotel = await ApiService.getHotelById(hotelId);
          hotels.add(hotel);
        } catch (e) {
          print('Failed to load hotel $hotelId: $e');
        }
      }
      
      if (mounted) {
        setState(() {
          _favoriteHotels = hotels;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat favorit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleFavoriteToggle(String hotelId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) return;
    
    // Show loading feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Memperbarui favorit...'),
          ],
        ),
        duration: Duration(seconds: 1),
        backgroundColor: AppColors.primaryColor,
      ),
    );
    
    final success = await favoriteProvider.toggleFavorite(
      authProvider.currentUser!.id,
      hotelId,
    );
    
    // Show result feedback and refresh list
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (success) {
        final isFavorite = favoriteProvider.isFavorite(hotelId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Text(isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit'),
              ],
            ),
            backgroundColor: isFavorite ? AppColors.accentColor : AppColors.grey,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Refresh the favorites list
        await _loadFavoriteHotels();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 16),
                Text('Gagal memperbarui favorit'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Favorit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavoriteHotels,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _favoriteHotels.isEmpty
              ? const EmptyState(
                  icon: Icons.favorite_border,
                  title: 'Belum ada Favorit',
                  message: 'Simpan hotel impianmu di sini agar mudah ditemukan nanti',
                )
              : RefreshIndicator(
                  onRefresh: _loadFavoriteHotels,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _favoriteHotels.length,
                    itemBuilder: (context, index) {
                      final hotel = _favoriteHotels[index];
                      return HotelCard(
                        hotel: hotel,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HotelDetailPage(hotel: hotel),
                            ),
                          );
                        },
                        onFavoritePressed: () {
                          _handleFavoriteToggle(hotel.id);
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
