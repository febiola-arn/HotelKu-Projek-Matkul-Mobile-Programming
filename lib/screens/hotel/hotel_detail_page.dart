import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/hotel.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../auth/login_page.dart';
import 'booking_page.dart';
import '../review/create_review_page.dart';

class HotelDetailPage extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailPage({super.key, required this.hotel});

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    await reviewProvider.fetchReviewsByHotelId(widget.hotel.id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Images
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image Gallery
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: widget.hotel.images.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.hotel.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.greyLight,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.greyLight,
                          child: const Icon(Icons.error),
                        ),
                      );
                    },
                  ),

                  // Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Image Indicator
                  Positioned(
                    bottom: AppSpacing.md,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.hotel.images.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? AppColors.white
                                : AppColors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Consumer2<FavoriteProvider, AuthProvider>(
                builder: (context, favoriteProvider, authProvider, child) {
                  final isFavorite = favoriteProvider.isFavorite(widget.hotel.id);
                  
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : AppColors.white,
                    ),
                    onPressed: () {
                      if (authProvider.currentUser != null) {
                        favoriteProvider.toggleFavorite(
                          authProvider.currentUser!.id,
                          widget.hotel.id,
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),

          // Hotel Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel Name
                  Text(
                    widget.hotel.name,
                    style: AppTextStyles.heading2,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 20,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          widget.hotel.address,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: widget.hotel.rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: AppColors.accentColor,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        widget.hotel.rating.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: AppSpacing.xl),

                  // Description
                  const Text(
                    'Tentang Hotel',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.hotel.description,
                    style: AppTextStyles.bodyMedium,
                  ),

                  const Divider(height: AppSpacing.xl),

                  // Facilities
                  const Text(
                    'Fasilitas',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: widget.hotel.facilities.map((facility) {
                      return Chip(
                        label: Text(facility),
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),

                  const Divider(height: AppSpacing.xl),

                  // Room Types
                  const Text(
                    'Tipe Kamar',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...widget.hotel.roomTypes.map((roomType) {
                    final isFull = roomType.availableRooms <= 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        title: Text(roomType.type),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kapasitas: ${roomType.capacity} orang'),
                            const SizedBox(height: 2),
                            Text(
                              isFull ? 'Maaf, Kamar Penuh' : 'Tersedia: ${roomType.availableRooms} unit',
                              style: TextStyle(
                                color: isFull ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          Helpers.formatCurrency(roomType.price),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isFull ? Colors.grey : AppColors.primaryColor,
                          ),
                        ),
                      ),
                    );
                  }),

                  const Divider(height: AppSpacing.xl),

                  // Reviews
                  const Text(
                    'Review',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, child) {
                      if (reviewProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final reviews = reviewProvider.getReviewsByHotelId(widget.hotel.id);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reviews.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                                child: Text(
                                  'Belum ada ulasan untuk hotel ini.',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            )
                          else
                            ...reviews.map((review) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(review.userAvatar),
                                            radius: 20,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  review.userName,
                                                  style: AppTextStyles.bodyMedium.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                RatingBarIndicator(
                                                  rating: review.rating,
                                                  itemBuilder: (context, index) => const Icon(
                                                    Icons.star,
                                                    color: AppColors.accentColor,
                                                  ),
                                                  itemCount: 5,
                                                  itemSize: 14.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        review.comment,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: AppSpacing.lg),
                          Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.rate_review_outlined),
                              label: const Text('Tulis Ulasan'),
                              onPressed: () async {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                                final user = authProvider.currentUser;

                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Silakan login untuk memberi ulasan.')),
                                  );
                                  return;
                                }

                                // Ensure we have latest bookings before checking
                                try {
                                  await bookingProvider.fetchBookingsByUserId(user.id);
                                } catch (_) {}

                                // Check if user has completed a booking for this hotel
                                final hasCompletedBooking = bookingProvider.completedBookings.any(
                                  (booking) => booking.hotelId == widget.hotel.id,
                                );

                                if (!hasCompletedBooking) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Anda harus menyelesaikan booking untuk memberi ulasan.')),
                                  );
                                  return;
                                }

                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CreateReviewPage(hotel: widget.hotel),
                                  ),
                                );

                                if (result == true && mounted) {
                                  // Refresh reviews if a new one was submitted
                                  _loadReviews();
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),

      // Book Now Button
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAdmin) {
            return const SizedBox.shrink();
          }
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mulai dari',
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        Helpers.formatCurrency(widget.hotel.pricePerNight),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Text(
                        'per malam',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.hotel.roomTypes.every((r) => r.availableRooms <= 0)
                        ? null
                        : () {
                            if (authProvider.currentUser == null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Login Diperlukan'),
                                  content: const Text(
                                    'Silakan login atau daftar terlebih dahulu untuk melakukan booking hotel.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Nanti'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LoginPage(),
                                          ),
                                        );
                                      },
                                      child: const Text('Login'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BookingPage(hotel: widget.hotel),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.hotel.roomTypes.every((r) => r.availableRooms <= 0)
                          ? Colors.grey
                          : AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                        widget.hotel.roomTypes.every((r) => r.availableRooms <= 0)
                            ? 'Kamar Penuh'
                            : 'Book Now'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
