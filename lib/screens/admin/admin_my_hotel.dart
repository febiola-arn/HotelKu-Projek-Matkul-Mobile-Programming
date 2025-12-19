import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hotel.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/empty_state.dart';
import 'admin_edit_hotel.dart';

class AdminMyHotelPage extends StatefulWidget {
  const AdminMyHotelPage({super.key});

  @override
  State<AdminMyHotelPage> createState() => _AdminMyHotelPageState();
}

class _AdminMyHotelPageState extends State<AdminMyHotelPage> {
  Hotel? _hotel;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHotel();
  }

  Future<void> _loadHotel() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final hotel = await ApiService.getAdminHotel(userId);
      
      if (mounted) {
        setState(() {
          _hotel = hotel;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Saya'),
        actions: [
          if (_hotel != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminEditHotelPage(hotel: _hotel!),
                  ),
                );
                if (result == true) {
                  _loadHotel();
                }
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingShimmer();
    }

    if (_error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Gagal Memuat Data',
        message: _error!,
        actionText: 'Coba Lagi',
        onActionPressed: _loadHotel,
      );
    }

    if (_hotel == null) {
      return const EmptyState(
        icon: Icons.hotel_outlined,
        title: 'Belum Ada Hotel',
        message: 'Anda belum mendaftarkan hotel Anda.',
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Gallary
          if (_hotel!.images.isNotEmpty)
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: _hotel!.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    _hotel!.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.greyLight,
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _hotel!.name,
                        style: AppTextStyles.heading2,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          _hotel!.rating.toString(),
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primaryColor, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${_hotel!.address}, ${_hotel!.city}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Fasilitas', style: AppTextStyles.heading3),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _hotel!.facilities.map((f) => Chip(
                    label: Text(f, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    side: BorderSide.none,
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Tentang Hotel', style: AppTextStyles.heading3),
                const SizedBox(height: AppSpacing.sm),
                Text(_hotel!.description, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                const Text('Tipe Kamar & Harga', style: AppTextStyles.heading3),
                const SizedBox(height: AppSpacing.sm),
                ..._hotel!.roomTypes.map((room) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(room.type),
                  subtitle: Text('Kapasitas: ${room.capacity} orang'),
                  trailing: Text(
                    'Rp ${room.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
