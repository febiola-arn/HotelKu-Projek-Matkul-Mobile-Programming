import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/hotel_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/empty_state.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../hotel/hotel_detail_page.dart';
import '../bookings/my_bookings_page.dart';
import '../profile/profile_page.dart';
import '../auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    // Gunakan post frame callback agar tidak error saat notifyListeners di dalam initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    await hotelProvider.fetchHotels();
    
    // Try to auto-login if credentials exist
    await authProvider.initialize();
    
    // Load favorites if logged in
    if (authProvider.currentUser != null && mounted) {
      final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
      await favoriteProvider.fetchFavoritesByUserId(authProvider.currentUser!.id);
    }
  }

  void _handleCityFilter(String? city) {
    setState(() {
      _selectedCity = city;
    });
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    hotelProvider.filterByCity(city);
  }

  void _handleFavoriteToggle(String hotelId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is logged in
    if (authProvider.currentUser == null) {
      // Show login dialog
      _showLoginRequired();
      return;
    }
    
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    
    // Show loading feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Memperbarui favorit...'),
          ],
        ),
        duration: Duration(seconds: 1),
        backgroundColor: AppColors.primaryColor,
      ),
    );
    
    final success = await favoriteProvider.toggleFavorite(
      authProvider.currentUser!.id, 
      hotelId,
    );
    
    // Show result feedback
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (success) {
        final isFavorite = favoriteProvider.isFavorite(hotelId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Text(isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit'),
              ],
            ),
            backgroundColor: isFavorite ? AppColors.accentColor : AppColors.grey,
            duration: const Duration(seconds: 2),
          ),
        );

        try {
          final count = await ApiService.getFavoriteCount(hotelId);
          if (mounted) {
            Provider.of<HotelProvider>(context, listen: false)
                .updateFavoriteCount(hotelId, count);
          }
        } catch (_) {}
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 16),
                Text('Gagal memperbarui favorit'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Diperlukan'),
        content: const Text('Silakan login terlebih dahulu untuk menggunakan fitur favorit.'),
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
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if trying to access Bookings or Profile without login
    if ((index == 1 || index == 2) && authProvider.currentUser == null) {
      _showLoginRequired();
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    final bool isAdmin = authProvider.isAdmin;

    final List<Widget> pages = [
      _buildHotelListPage(),
      // Conditionally add MyBookingsPage if not admin
      if (!isAdmin)
        authProvider.currentUser != null
            ? const MyBookingsPage()
            : _buildLoginRequiredPage(),
      authProvider.currentUser != null
          ? const ProfilePage()
          : _buildLoginRequiredPage(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      // Conditionally add Booking tab if not admin
      if (!isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          activeIcon: Icon(Icons.book_rounded),
          label: 'Booking',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outlined),
        activeIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _handleBottomNavTap,
        items: navItems,
      ),
    );
  }

  Widget _buildLoginRequiredPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 80,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Login Diperlukan',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Silakan login untuk mengakses fitur ini',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              icon: const Icon(Icons.login_rounded),
              label: const Text('Login Sekarang'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelListPage() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.8),
                      AppColors.accentColor.withOpacity(0.6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            final user = authProvider.currentUser;
                            return Text(
                              user != null ? 'Halo, ${user.name.split(' ')[0]}! 👋' : 'Halo! 👋',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          'Mau kemana hari ini?',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: HotelSearchDelegate(),
                  );
                },
              ),
            ],
          ),

          // City Selection Section
          SliverToBoxAdapter(
            child: Consumer<HotelProvider>(
              builder: (context, hotelProvider, child) {
                final cities = hotelProvider.cities;
                
                if (cities.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  margin: const EdgeInsets.all(AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_city_rounded,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Text(
                            'Pilih Kota Tujuan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          // All Cities Chip
                          _buildCityChip('Semua Kota', null, Icons.apps_rounded),
                          // Individual City Chips
                          ...cities.map((city) {
                            IconData icon;
                            switch (city.toLowerCase()) {
                              case 'jakarta':
                                icon = Icons.location_city;
                                break;
                              case 'bali':
                                icon = Icons.beach_access;
                                break;
                              case 'bandung':
                                icon = Icons.terrain;
                                break;
                              case 'surabaya':
                                icon = Icons.business;
                                break;
                              case 'yogyakarta':
                                icon = Icons.temple_buddhist;
                                break;
                              case 'lombok':
                                icon = Icons.water;
                                break;
                              default:
                                icon = Icons.location_on;
                            }
                            return _buildCityChip(city, city, icon);
                          }),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Hotel List
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: Consumer2<HotelProvider, FavoriteProvider>(
              builder: (context, hotelProvider, favoriteProvider, child) {
                if (hotelProvider.isLoading) {
                  return const SliverToBoxAdapter(
                    child: LoadingShimmer(),
                  );
                }

                if (hotelProvider.error != null) {
                  return SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.error_outline,
                      title: 'Terjadi Kesalahan',
                      message: hotelProvider.error!,
                      actionText: 'Coba Lagi',
                      onActionPressed: _loadData,
                    ),
                  );
                }

                final hotels = hotelProvider.hotels;

                if (hotels.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.hotel_outlined,
                      title: 'Tidak Ada Hotel',
                      message: 'Belum ada hotel yang tersedia di kota ini',
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final hotel = hotels[index];

                      return HotelCard(
                        hotel: hotel,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HotelDetailPage(hotel: hotel),
                            ),
                          );
                        },
                        onFavoritePressed: () {
                          _handleFavoriteToggle(hotel.id);
                        },
                      );
                    },
                    childCount: hotels.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityChip(String label, String? cityValue, IconData icon) {
    final isSelected = _selectedCity == cityValue;
    
    return InkWell(
      onTap: () => _handleCityFilter(cityValue),
      borderRadius: BorderRadius.circular(AppBorderRadius.circular),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.accentColor,
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(AppBorderRadius.circular),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : AppColors.greyLight,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.white : AppColors.primaryColor,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Search Delegate (unchanged)
class HotelSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Cari hotel berdasarkan nama atau kota'),
      );
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    // Trigger search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HotelProvider>(context, listen: false).searchHotels(query);
    });

    return Consumer2<HotelProvider, FavoriteProvider>(
      builder: (context, hotelProvider, favoriteProvider, child) {
        if (hotelProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final hotels = hotelProvider.hotels;

        if (hotels.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off,
            title: 'Tidak Ditemukan',
            message: 'Tidak ada hotel yang sesuai dengan pencarian',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: hotels.length,
          itemBuilder: (context, index) {
            final hotel = hotels[index];
            final authProvider = Provider.of<AuthProvider>(context, listen: false);

            return HotelCard(
              hotel: hotel,
              onTap: () {
                close(context, hotel.name);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HotelDetailPage(hotel: hotel),
                  ),
                );
              },
              onFavoritePressed: () {
                if (authProvider.currentUser != null) {
                  favoriteProvider
                      .toggleFavorite(
                        authProvider.currentUser!.id,
                        hotel.id,
                      )
                      .then((success) async {
                    if (success) {
                      try {
                        final count = await ApiService.getFavoriteCount(hotel.id);
                        Provider.of<HotelProvider>(context, listen: false)
                            .updateFavoriteCount(hotel.id, count);
                      } catch (_) {}
                    }
                  });
                }
              },
            );
          },
        );
      },
    );
  }
}
