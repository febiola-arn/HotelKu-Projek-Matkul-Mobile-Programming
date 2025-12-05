import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';
import '../../widgets/empty_state.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await bookingProvider.fetchBookingsByUserId(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Saya'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Selesai'),
            Tab(text: 'Dibatalkan'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(bookingProvider.bookings),
              _buildBookingList(bookingProvider.upcomingBookings),
              _buildBookingList(bookingProvider.completedBookings),
              _buildBookingList(bookingProvider.cancelledBookings),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return const EmptyState(
        icon: Icons.book_outlined,
        title: 'Tidak Ada Booking',
        message: 'Anda belum memiliki booking',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = AppColors.success;
        break;
      case BookingStatus.pending:
        statusColor = AppColors.warning;
        break;
      case BookingStatus.completed:
        statusColor = AppColors.info;
        break;
      case BookingStatus.cancelled:
        statusColor = AppColors.error;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.hotelName,
                    style: AppTextStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    booking.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Booking Details
            _buildDetailRow(
              Icons.meeting_room_outlined,
              'Tipe Kamar',
              booking.roomType,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Check-in',
              Helpers.formatDate(booking.checkIn),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Check-out',
              Helpers.formatDate(booking.checkOut),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              Icons.nights_stay_outlined,
              'Jumlah Malam',
              '${booking.totalNights} malam',
            ),

            const Divider(height: AppSpacing.lg),

            // Total Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Harga',
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  Helpers.formatCurrency(booking.totalPrice),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),

            // Cancel Button (only for pending/confirmed bookings)
            if (booking.status == BookingStatus.pending ||
                booking.status == BookingStatus.confirmed) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _handleCancelBooking(booking),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Batalkan Booking'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall,
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _handleCancelBooking(Booking booking) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Batalkan Booking',
      message: 'Apakah Anda yakin ingin membatalkan booking ini?',
      confirmText: 'Ya, Batalkan',
      cancelText: 'Tidak',
    );

    if (!confirmed) return;

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProvider.cancelBooking(booking.id);

    if (!mounted) return;

    if (success) {
      Helpers.showSnackbar(context, 'Booking berhasil dibatalkan');
    } else {
      Helpers.showSnackbar(
        context,
        bookingProvider.error ?? 'Gagal membatalkan booking',
        isError: true,
      );
    }
  }
}
