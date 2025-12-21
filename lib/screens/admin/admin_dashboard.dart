import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/booking.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'admin_my_hotel.dart';
import 'admin_bookings.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatefulWidget {
  const _AdminDashboardView();

  @override
  State<_AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<_AdminDashboardView> {
  final _searchController = TextEditingController();
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    _searchController.addListener(() {
      Provider.of<AdminProvider>(context, listen: false)
          .searchBookings(_searchController.text);
    });

    _autoTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        await adminProvider.fetchBookings(userId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _autoTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      await adminProvider.fetchBookings(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Halo, ${user?.name ?? 'Admin'} 👋',
              style: AppTextStyles.heading2,
            ),
            const Text(
              'Berikut ringkasan hotel Anda hari ini',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stats Cards
            Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Pendapatan',
                            Helpers.formatCurrency(adminProvider.totalRevenue),
                            Icons.monetization_on,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            'Booking Aktif',
                            adminProvider.activeBookings.toString(),
                            Icons.book_online,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Favorit',
                            adminProvider.totalFavorites.toString(),
                            Icons.favorite,
                            Colors.red,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            'Rata-rata Rating',
                            '4.5', // Placeholder
                            Icons.star,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Quick Actions
            const Text(
              'Menu Admin',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            
            _buildMenuCard(
              'Kelola Hotel',
              'Update harga, foto, dan fasilitas',
              Icons.hotel,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminMyHotelPage()),
                );
              },
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _buildMenuCard(
              'Daftar Pesanan',
              'Lihat dan kelola semua pesanan masuk',
              Icons.list_alt,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminBookingsPage()),
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),
            
            // Recent Bookings Section
            const Text(
              'Pesanan Terbaru',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan ID booking atau nama tamu...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.greyLight.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (adminProvider.error != null) {
                  return Center(child: Text(adminProvider.error!));
                }
                if (adminProvider.bookings.isEmpty) {
                  return const Center(child: Text('Tidak ada pesanan.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: adminProvider.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = adminProvider.bookings[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        side: BorderSide(color: AppColors.greyLight),
                      ),
                      child: ListTile(
                        title: Text(booking.guestName),
                        trailing: Text(
                          Helpers.formatCurrency(booking.totalPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(color: AppColors.greyLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading3),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
