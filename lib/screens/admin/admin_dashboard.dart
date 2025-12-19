import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'admin_my_hotel.dart';
import 'admin_bookings.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<Booking> _recentBookings = [];
  double _totalRevenue = 0;
  int _activeBookings = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) throw Exception('User not logged in');

      final bookings = await ApiService.getAdminBookings(userId);
      
      double revenue = 0;
      int active = 0;
      
      for (var b in bookings) {
        if (b.status == BookingStatus.confirmed || b.status == BookingStatus.completed) {
          revenue += b.totalPrice;
        }
        if (b.status == BookingStatus.confirmed || b.status == BookingStatus.pending) {
          active++;
        }
      }

      if (mounted) {
        setState(() {
          _recentBookings = bookings.take(3).toList();
          _totalRevenue = revenue;
          _activeBookings = active;
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
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pendapatan',
                    Helpers.formatCurrency(_totalRevenue),
                    Icons.monetization_on,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'Booking Aktif',
                    '$_activeBookings',
                    Icons.book_online,
                    Colors.blue,
                  ),
                ),
              ],
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
            
            // Recent Bookings Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pesanan Terbaru',
                  style: AppTextStyles.heading3,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminBookingsPage()),
                    );
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xl), child: CircularProgressIndicator()))
            else if (_error != null)
              Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Text(_error!, style: const TextStyle(color: Colors.red))))
            else if (_recentBookings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Text('Belum ada pesanan terbaru'),
                ),
              )
            else
              ..._recentBookings.map((booking) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  side: BorderSide(color: AppColors.greyLight),
                ),
                child: ListTile(
                  title: Text(booking.guestName),
                  subtitle: Text(booking.roomType),
                  trailing: Text(
                    Helpers.formatCurrency(booking.totalPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                  ),
                ),
              )).toList(),
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
