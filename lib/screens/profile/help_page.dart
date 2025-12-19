import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FAQ (Sering Ditanyakan)',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildExpansionTile(
              'Bagaimana cara booking hotel?',
              'Pilih hotel yang diinginkan di halaman beranda, pilih tipe kamar, tentukan tanggal menginap, lalu lakukan pembayaran.',
            ),
             _buildExpansionTile(
              'Apakah bisa membatalkan pesanan?',
              'Pembatalan bisa dilakukan maksimal 24 jam sebelum waktu check-in melalui menu "Booking Saya".',
            ),
             _buildExpansionTile(
              'Metode pembayaran apa yang tersedia?',
              'Saat ini kami mendukung transfer bank, e-wallet (GoPay, OVO), dan kartu kredit.',
            ),
             _buildExpansionTile(
              'Bagaimana jika saya telat check-in?',
              'Kamar Anda akan tetap aman hingga pukul 12 siang hari berikutnya. Namun disarankan menghubungi pihak hotel jika datang terlambat.',
            ),

            const SizedBox(height: AppSpacing.xl),
            
            const Text(
              'Hubungi Kami',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            
            _buildContactCard(
              Icons.email, 
              'Email Support', 
              'support@hotelku.com',
              Colors.red[100]!,
              Colors.red,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildContactCard(
              Icons.phone, 
              'Call Center', 
              '+62 21 555 1234',
              Colors.green[100]!,
              Colors.green,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildContactCard(
              Icons.chat, 
              'WhatsApp', 
              '+62 812 3456 7890',
              Colors.green[100]!,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        side: const BorderSide(color: AppColors.greyLight),
      ),
      child: ExpansionTile(
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySmall),
              Text(subtitle, style: AppTextStyles.heading3.copyWith(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
