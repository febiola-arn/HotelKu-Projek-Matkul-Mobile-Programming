import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hotel.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../bookings/my_bookings_page.dart';

class BookingPage extends StatefulWidget {
  final Hotel hotel;

  const BookingPage({super.key, required this.hotel});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String? _selectedRoomType;
  final _guestNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();
  final _specialRequestController = TextEditingController();

  int get _totalNights {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return Booking.calculateNights(_checkInDate!, _checkOutDate!);
  }

  double get _totalPrice {
    if (_selectedRoomType == null) return 0;
    final roomType = widget.hotel.roomTypes.firstWhere(
      (rt) => rt.type == _selectedRoomType,
    );
    return Booking.calculateTotalPrice(roomType.price, _totalNights);
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Page-level guard for admin
    if (authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Helpers.showSnackbar(context, 'Admin tidak dapat mengakses halaman booking.', isError: true);
        Navigator.of(context).pop();
      });
      return;
    }

    // Pre-fill guest info from current user
    if (authProvider.currentUser != null) {
      _guestNameController.text = authProvider.currentUser!.name;
      _guestPhoneController.text = authProvider.currentUser!.phone;
    }
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        // Reset check-out if it's before check-in
        if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      Helpers.showSnackbar(
        context,
        'Pilih tanggal check-in terlebih dahulu',
        isError: true,
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: _checkInDate!.add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  Future<void> _handleBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_checkInDate == null) {
      Helpers.showSnackbar(
        context,
        'Pilih tanggal check-in',
        isError: true,
      );
      return;
    }

    if (_checkOutDate == null) {
      Helpers.showSnackbar(
        context,
        'Pilih tanggal check-out',
        isError: true,
      );
      return;
    }

    if (_selectedRoomType == null) {
      Helpers.showSnackbar(
        context,
        'Pilih tipe kamar',
        isError: true,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      Helpers.showSnackbar(
        context,
        'Anda harus login terlebih dahulu',
        isError: true,
      );
      return;
    }

    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.currentUser!.id,
      hotelId: widget.hotel.id,
      hotelName: widget.hotel.name,
      roomType: _selectedRoomType!,
      checkIn: _checkInDate!,
      checkOut: _checkOutDate!,
      totalNights: _totalNights,
      totalPrice: _totalPrice,
      status: BookingStatus.pending,
      bookingDate: DateTime.now(),
      guestName: _guestNameController.text.trim(),
      guestPhone: _guestPhoneController.text.trim(),
      specialRequest: _specialRequestController.text.trim(),
    );

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProvider.createBooking(booking);

    if (!mounted) return;

    if (success) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Booking Berhasil!',
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Booking Anda telah kami terima. Silakan cek status booking Anda di menu Pesanan Saya.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Close all pages until we get to the home page, then push MyBookingsPage.
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MyBookingsPage()),
                      ModalRoute.withName('/home'),
                    );
                  },
                  child: const Text('Lihat Pesanan Saya'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      );
    } else {
      Helpers.showSnackbar(
        context,
        bookingProvider.error ?? 'Gagal membuat booking',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Hotel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotel.name,
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              widget.hotel.city,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Check-in Date
              const Text(
                'Tanggal Check-in',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _selectCheckInDate,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyLight),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.grey),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        _checkInDate == null
                            ? 'Pilih tanggal check-in'
                            : Helpers.formatDate(_checkInDate!),
                        style: TextStyle(
                          color: _checkInDate == null
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Check-out Date
              const Text(
                'Tanggal Check-out',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _selectCheckOutDate,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyLight),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.grey),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        _checkOutDate == null
                            ? 'Pilih tanggal check-out'
                            : Helpers.formatDate(_checkOutDate!),
                        style: TextStyle(
                          color: _checkOutDate == null
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Room Type
              const Text(
                'Tipe Kamar',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                value: _selectedRoomType,
                decoration: const InputDecoration(
                  hintText: 'Pilih tipe kamar',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
                items: widget.hotel.roomTypes.map((roomType) {
                  return DropdownMenuItem(
                    value: roomType.type,
                    child: Text(
                      '${roomType.type} - ${Helpers.formatCurrency(roomType.price)}',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoomType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih tipe kamar';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Guest Name
              TextFormField(
                controller: _guestNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tamu',
                  hintText: 'Masukkan nama tamu',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tamu tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Guest Phone
              TextFormField(
                controller: _guestPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  hintText: 'Masukkan nomor telepon',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  if (!Helpers.isValidPhone(value)) {
                    return 'Nomor telepon tidak valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Special Request
              TextFormField(
                controller: _specialRequestController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Permintaan Khusus (Opsional)',
                  hintText: 'Contoh: Late check-in, extra bed, dll',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Price Summary
              if (_totalNights > 0 && _selectedRoomType != null)
                Card(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Jumlah Malam'),
                            Text(
                              '$_totalNights malam',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Harga'),
                            Text(
                              Helpers.formatCurrency(_totalPrice),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.xl),

              // Confirm Button
              Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: bookingProvider.isLoading ? null : _handleBooking,
                      child: bookingProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Text('Konfirmasi Booking'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
