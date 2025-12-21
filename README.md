HotelKu - Mobile Hotel Reservation

Tim Pengembang
- Febiola Kristin Aruan - 241712059
- Rael Gilbert Manurung - 241712070
- Vaidon Selo Sinambela - 241712052
- Nadya Lahfah - 241712051
- Elaine Keisha Pasaribu - 241712057

Deskripsi Singkat Aplikasi
HotelKu merupakan aplikasi reservasi hotel berbasis mobile yang dirancang untuk mempermudah pengguna dalam mencari dan memesan penginapan secara efisien. Aplikasi ini menghubungkan pengguna (Customer) dengan pemilik properti (Hotel Admin) melalui sistem yang terintegrasi, menggunakan arsitektur Client-Server dengan Flutter sebagai frontend dan PHP Native sebagai backend API.

Daftar Fitur
Fitur Pengguna (Customer)
- Multi-role Authentication: Login dan Register sebagai Customer atau Hotel Admin.
- Hotel Discovery: Pencarian hotel berdasarkan lokasi
- Detail Hotel: Informasi lengkap mengenai fasilitas, gambar, dan tipe kamar.
- Booking System: Pemesanan kamar hotel secara real-time.
- My Bookings: Manajemen riwayat pemesanan dan status reservasi.
- Favorites : Menyimpan hotel pilihan untuk akses cepat.
- User Profile: Pengaturan profil dan informasi akun.
- Rate & Review: Memberikan umpan balik dan review terhadap hotel yang telah dipesan.

Fitur Admin (Hotel Admin)
- Dashboard Admin: Ringkasan data hotel dan reservasi bagi pemilik hotel.
- Manage Hotel: Edit informasi hotel, fasilitas, dan tipe kamar.
- Manage Bookings: Memantau dan mengelola pesanan yang masuk.


## Perbandingan Fitur Sebelum dan Sesudah Pengembangan

### Dashboard Customer
**Sebelum Pengembangan:**
- Pencarian hotel dasar
- Pemesanan kamar
- Melihat daftar booking
- Sistem rating sederhana (1x review per hotel)
- Manajemen profil dasar

**Sesudah Pengembangan:**
- Pencarian hotel dengan filter lengkap (lokasi, rating, fasilitas)
- Sistem booking real-time dengan konfirmasi instan
- Multiple reviews (1 review per transaksi booking)
- Opsi review anonim
- Manajemen booking yang lebih detail
- Notifikasi status booking
- Sistem favorit yang ditingkatkan
- Riwayat transaksi lengkap

### Dashboard Admin
**Sebelum Pengembangan:**
- Daftar pesanan
- Manajemen kamar dasar
- Informasi hotel statis

**Sesudah Pengembangan:**
- Dashboard analitik dengan statistik pemesanan
- Manajemen fasilitas hotel yang dinamis
- Auto-checkout otomatis pukul 12:00 siang
- Sistem manajemen review yang komprehensif
- Filter dan pencarian pesanan yang lebih baik
- Tampilan daftar pesanan yang lebih rapi (tanpa ID pesanan)
- Kemampuan mengedit detail hotel secara lengkap
- Manajemen gambar hotel yang lebih baik

## Technical Stack Application
- Frontend Framework: Flutter 3.35.2 (Stable)
- Programming Language: Dart 3.9.0
- Backend API: PHP Native 8.0+
- Database: MySQL (MariaDB)
- State Management: Provider
- Local Server: XAMPP / PHP Built-in Server
- Public Access: Ngrok for remote API access

How to Run Application
### Cara 1: Menggunakan Server Ngrok (Direkomendasikan)
Aplikasi ini menggunakan server backend yang sudah di-host melalui Ngrok. Berikut cara menjalankannya:

1. **Persiapan Awal**
   - Pastikan Anda memiliki koneksi internet yang stabil
   - Install Flutter dan Dart SDK di komputer Anda
   - Install Chrome browser (untuk menjalankan di web)

2. **Jalankan Aplikasi Flutter**
   ```bash
   # Clone repository
   git clone [URL_REPOSITORY_ANDA]
   cd hotelku

   # Install dependencies
   flutter pub get

   # Jalankan aplikasi
   flutter run -d chrome
   ```
   - Aplikasi akan otomatis terhubung ke server backend yang sudah disediakan
   - Tidak perlu menjalankan server lokal

### Cara 2: Menjalankan Server Lokal (Opsional)
Jika Anda ingin menjalankan server sendiri:

1. **Persiapan Database**
   - Pastikan XAMPP (MySQL) sudah aktif
   - Buat database baru bernama `hotelku` di phpMyAdmin
   - Import file `database.sql` ke dalam database tersebut

2. **Jalankan Backend API**
   - Buka folder project di terminal
   - Jalankan perintah:
     ```powershell
     php -S localhost:8000 -t .
     ```
   - Pastikan jendela terminal server tetap terbuka

3. **Konfigurasi Aplikasi**
   - Buka file `lib/utils/constants.dart`
   - Ubah `baseUrl` menjadi `'http://localhost:8000/php_api'`

4. **Jalankan Aplikasi Flutter**
   ```bash
   flutter pub get
   flutter run -d chrome
   ```

### Catatan Penting
- Aplikasi ini membutuhkan koneksi internet untuk mengakses server backend
- Pastikan tidak ada firewall yang memblokir koneksi ke server
- Untuk masalah koneksi, pastikan URL di `lib/utils/constants.dart` mengarah ke server yang benar

### Kontak Pengembang
Jika menemui kendala, silakan hubungi tim pengembang melalui email atau platform lainnya.

---
*Proyek ini dikembangkan sebagai tugas akhir mata kuliah Mobile Programming.*

**Server Status**: Online (Terakhir diperbarui: 21 Desember 2024)*
