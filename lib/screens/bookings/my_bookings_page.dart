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

            // Action Buttons
            if (booking.status == BookingStatus.pending) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handlePayment(booking),
                  child: const Text('Bayar Sekarang'),
                ),
              ),
            ],

            // Cancel Button (only for pending/confirmed bookings)
            if (booking.status == BookingStatus.pending ||
                booking.status == BookingStatus.confirmed) ...[
              const SizedBox(height: AppSpacing.sm),
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

  void _handlePayment(Booking booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Metode Pembayaran',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.qr_code, color: AppColors.primaryColor),
              title: const Text('QRIS'),
              subtitle: const Text('Scan QR Code'),
              onTap: () {
                Navigator.pop(context);
                _showQrisDialog(booking);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.account_balance, color: AppColors.primaryColor),
              title: const Text('Transfer Bank'),
              subtitle: const Text('BCA, Mandiri, BNI'),
              onTap: () {
                Navigator.pop(context);
                _showBankTransferDialog(booking);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQrisDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran QRIS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.grey),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2, size: 150),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Scan QR Code di atas untuk membayar',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              Helpers.formatCurrency(booking.totalPrice),
              style: AppTextStyles.heading3.copyWith(color: AppColors.primaryColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(booking);
            },
            child: const Text('Saya Sudah Bayar'),
          ),
        ],
      ),
    );
  }

  void _showBankTransferDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Bank'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Silakan transfer ke salah satu rekening berikut:'),
            const SizedBox(height: AppSpacing.md),
            _buildBankItem('BCA', '880012345678', 'PT HotelKu Indonesia'),
            const SizedBox(height: AppSpacing.sm),
            _buildBankItem('Mandiri', '1230009876543', 'PT HotelKu Indonesia'),
            const SizedBox(height: AppSpacing.lg),
            const Center(child: Text('Total Pembayaran:')),
            Center(
              child: Text(
                Helpers.formatCurrency(booking.totalPrice),
                style: AppTextStyles.heading3.copyWith(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(booking);
            },
            child: const Text('Saya Sudah Transfer'),
          ),
        ],
      ),
    );
  }

  Widget _buildBankItem(String bank, String number, String name) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance, color: AppColors.grey),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(number, style: const TextStyle(fontSize: 16)),
                Text(name, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(Booking booking) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Remove loading
    Navigator.pop(context);

    // Update status
    final success = await bookingProvider.updateBookingStatus(
      booking.id, 
      BookingStatus.confirmed,
    );

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pembayaran Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 64),
              const SizedBox(height: AppSpacing.md),
              const Text('Terima kasih! Pembayaran Anda telah kami terima.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } else {
      Helpers.showSnackbar(
        context,
        bookingProvider.error ?? 'Gagal memproses pembayaran',
        isError: true,
      );
    }
  }

  Future<void> _handleCancelBooking(Booking booking) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Batalkan Booking',
      message: 'Apakah Anda yakin ingin membatalkan booking ini?',
      confirmText: 'Ya, Batalkan',
      cancelText: 'Tidak',
    );

    if (!confirmed || !mounted) return;

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

