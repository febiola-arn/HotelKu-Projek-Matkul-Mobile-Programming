import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/hotel_card.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../hotel/hotel_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Favorit'),
      ),
      body: Consumer3<FavoriteProvider, HotelProvider, AuthProvider>(
        builder: (context, favoriteProvider, hotelProvider, authProvider, child) {
          if (favoriteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteIds = favoriteProvider.favorites.map((f) => f.hotelId).toSet();
          final favoriteHotels = hotelProvider.hotels
              .where((hotel) => favoriteIds.contains(hotel.id))
              .toList();

          if (favoriteHotels.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'Belum ada Favorit',
              message: 'Simpan hotel impianmu di sini agar mudah ditemukan nanti',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: favoriteHotels.length,
            itemBuilder: (context, index) {
              final hotel = favoriteHotels[index];
              return HotelCard(
                hotel: hotel,
                isFavorite: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HotelDetailPage(hotel: hotel),
                    ),
                  );
                },
                onFavoritePressed: () {
                  if (authProvider.currentUser != null) {
                    favoriteProvider.toggleFavorite(
                      authProvider.currentUser!.id,
                      hotel.id,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
