import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _language = 'Bahasa Indonesia';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.md),
          _buildSectionHeader('Umum'),
          SwitchListTile(
            title: const Text('Notifikasi'),
            subtitle: const Text('Terima update promo dan status booking'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: AppColors.primaryColor,
          ),
          SwitchListTile(
            title: const Text('Mode Gelap'),
            subtitle: const Text('Tampilan gelap agar nyaman di mata'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              // Note: Theme toggling logic would go here
            },
            activeColor: AppColors.primaryColor,
          ),
          ListTile(
            title: const Text('Bahasa'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Note: Language selection dialog would go here
            },
          ),
          
          const Divider(height: AppSpacing.xl),
          _buildSectionHeader('Info Aplikasi'),
          
          const ListTile(
            title: Text('Versi Aplikasi'),
            trailing: Text('1.0.0', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ListTile(
            title: const Text('Syarat & Ketentuan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Kebijakan Privasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, 
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
