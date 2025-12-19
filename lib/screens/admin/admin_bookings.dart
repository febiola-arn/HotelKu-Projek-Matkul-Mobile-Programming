import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/empty_state.dart';
import 'package:intl/intl.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) throw Exception('User not logged in');

      final bookings = await ApiService.getAdminBookings(userId);
      
      if (mounted) {
        setState(() {
          _bookings = bookings;
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
        title: const Text('Daftar Pesanan'),
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
        title: 'Gagal Memuat Pesanan',
        message: _error!,
        actionText: 'Coba Lagi',
        onActionPressed: _loadBookings,
      );
    }

    if (_bookings.isEmpty) {
      return const EmptyState(
        icon: Icons.book_online_outlined,
        title: 'Belum Ada Pesanan',
        message: 'Belum ada pesanan yang masuk untuk hotel Anda.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.lg)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}...',
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    _buildStatusChip(booking.status),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    Text(booking.guestName, style: AppTextStyles.heading3),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('dd MMM').format(booking.checkIn)} - ${DateFormat('dd MMM yyyy').format(booking.checkOut)}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.hotel, size: 16, color: AppColors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${booking.roomType}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran', style: AppTextStyles.bodyMedium),
                    Text(
                      'Rp ${booking.totalPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.heading3.copyWith(color: AppColors.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String label = status.displayName;

    switch (status) {
      case BookingStatus.confirmed:
        color = AppColors.success;
        break;
      case BookingStatus.pending:
        color = AppColors.warning;
        break;
      case BookingStatus.cancelled:
        color = AppColors.error;
        break;
      case BookingStatus.completed:
        color = AppColors.primaryColor;
        break;
      default:
        color = AppColors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
