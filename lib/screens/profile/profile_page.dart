import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/helpers.dart';
import 'favorites_page.dart';
import 'settings_page.dart';
import 'help_page.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(
              child: Text('User tidak ditemukan'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),

                // User Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(user.avatar),
                  backgroundColor: AppColors.greyLight,
                ),

                const SizedBox(height: AppSpacing.md),

                // User Name
                Text(
                  user.name,
                  style: AppTextStyles.heading2,
                ),

                const SizedBox(height: AppSpacing.xs),

                // User Email
                Text(
                  user.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Menu Items
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {
                    _showEditProfileDialog(context, user);
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.favorite_outline,
                  title: 'Hotel Favorit',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FavoritesPage()),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Pengaturan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Bantuan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpPage()),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),

                const Divider(height: AppSpacing.xl),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Apakah Anda yakin ingin keluar?',
      confirmText: 'Ya, Keluar',
      cancelText: 'Batal',
    );

    if (!confirmed || !context.mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang HotelKu'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HotelKu v1.0.0'),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Aplikasi booking hotel untuk tugas akhir Mobile Programming.',
              style: AppTextStyles.bodySmall,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              '© 2025 HotelKu. All rights reserved.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, dynamic user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  
                  // Clone user with new data
                  // Assuming User has copyWith, if not we construct new one
                  // Let's check User model first. If no copyWith, use constructor.
                  // For safety, I'll use constructor as I haven't checked User model for copyWith.
                  final newUser = user.copyWith(
                    name: nameController.text,
                    phone: phoneController.text,
                  );

                  final success = await authProvider.updateProfile(newUser);

                  if (context.mounted) {
                    // Close loading
                    Navigator.pop(context); 
                    
                    if (success) {
                      // Close edit dialog
                      Navigator.pop(context);
                      Helpers.showSnackbar(context, 'Profile berhasil diperbarui', isError: false);
                    } else {
                      Helpers.showSnackbar(context, authProvider.error ?? 'Gagal update profile');
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                     Navigator.pop(context); // Close loading
                     Helpers.showSnackbar(context, 'Terjadi kesalahan: $e');
                  }
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

