import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hotel.dart';
import '../../models/user.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class CreateReviewPage extends StatefulWidget {
  final Hotel hotel;

  const CreateReviewPage({super.key, required this.hotel});

  @override
  State<CreateReviewPage> createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  final _formKey = GlobalKey<FormState>();
  double _rating = 3.0;
  final _commentController = TextEditingController();
  bool _isLoading = false;
  bool _loadingBookings = true;
  bool _showName = true;
  List<Booking> _eligibleBookings = [];
  String? _selectedBookingId;

  @override
  void initState() {
    super.initState();
    _loadEligibleBookings();
  }

  Future<void> _loadEligibleBookings() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.currentUser;
      if (user == null) {
        setState(() {
          _loadingBookings = false;
        });
        return;
      }
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      if (bookingProvider.bookings.isEmpty) {
        await bookingProvider.fetchBookingsByUserId(user.id);
      }
      final eligible = bookingProvider.completedBookings
          .where((b) => b.hotelId == widget.hotel.id)
          .toList();
      setState(() {
        _eligibleBookings = eligible;
        _selectedBookingId = eligible.isNotEmpty ? eligible.first.id : null;
        _loadingBookings = false;
      });
    } catch (_) {
      setState(() {
        _eligibleBookings = [];
        _selectedBookingId = null;
        _loadingBookings = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk memberi ulasan.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      if (_selectedBookingId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih transaksi (booking) yang ingin diulas.')),
        );
        setState(() { _isLoading = false; });
        return;
      }
      final reviewData = {
        'hotel_id': widget.hotel.id,
        'user_id': user.id,
        'rating': _rating,
        'comment': _commentController.text,
        'user_name': user.name,
        'user_avatar': user.avatar,
        'booking_id': _selectedBookingId,
        'anonymous': !_showName,
      };

      await ApiService.createReview(reviewData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan berhasil dikirim! Terima kasih.')),
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim ulasan: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tulis Ulasan untuk ${widget.hotel.name}'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Transaksi', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              if (_loadingBookings)
                const Center(child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator(),
                ))
              else if (_eligibleBookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text('Tidak ada transaksi selesai untuk diulas.', style: AppTextStyles.bodySmall),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedBookingId,
                  items: _eligibleBookings.map((b) {
                    final label = '${b.roomType} • ${b.checkIn.day}/${b.checkIn.month} - ${b.checkOut.day}/${b.checkOut.month}/${b.checkOut.year}';
                    return DropdownMenuItem(
                      value: b.id,
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedBookingId = v),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(AppBorderRadius.lg)),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Rating Anda',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: AppColors.secondaryColor,
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tampilkan nama akun saya'),
                value: _showName,
                onChanged: (v) => setState(() => _showName = v),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Komentar Anda',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Bagikan pengalaman Anda menginap di sini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(AppBorderRadius.lg)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Komentar tidak boleh kosong.';
                  }
                  if (value.length < 10) {
                    return 'Komentar minimal 10 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Kirim Ulasan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
