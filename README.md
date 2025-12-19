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
- Hotel Discovery: Pencarian hotel berdasarkan lokasi, rating, dan kategori.
- Detail Hotel: Informasi lengkap mengenai fasilitas, gambar, dan tipe kamar.
- Booking System: Pemesanan kamar hotel secara real-time.
- My Bookings: Manajemen riwayat pemesanan dan status reservasi.
- Favorites : Menyimpan hotel pilihan untuk akses cepat.
- User Profile: Pengaturan profil dan informasi akun.

Fitur Admin (Hotel Admin)
- Dashboard Admin: Ringkasan data hotel dan reservasi bagi pemilik hotel.
- Manage Hotel: Edit informasi hotel, fasilitas, dan tipe kamar.
- Manage Bookings: Memantau dan mengelola pesanan yang masuk.

Technical Stack Application
- Frontend Framework: Flutter 3.35.2 (Stable)
- Programming Language: Dart 3.9.0
- Backend API: PHP Native 8.0+
- Database: MySQL (MariaDB)
- State Management: Provider
- Local Server: XAMPP / PHP Built-in Server

How to Run Application
1. Persiapan Database
2. Pastikan XAMPP (MySQL) sudah aktif.
3. Buat database baru bernama `hotelku` di phpMyAdmin.
4. Import file `hotelku.sql` ke dalam database tersebut.
5. Jalankan Backend API
6. Buka folder project di terminal atau File Explorer.
7. Jalankan file `start_server.bat` (Double-click) atau jalankan perintah:
   ```powershell
   php -S localhost:8000 -t .
   ```
8. Pastikan jendela terminal server tetap terbuka selama aplikasi digunakan.

Jalankan Aplikasi Flutter
1. Pastikan koneksi internet stabil (untuk load assets/images).
2. Di terminal project, jalankan:
   ```bash
   flutter pub get
   flutter run -d chrome
   ```
   *(Atau pilih device emulator/physical device yang tersedia)*

---
*Proyek ini dikembangkan sebagai tugas akhir mata kuliah Mobile Programming.*
