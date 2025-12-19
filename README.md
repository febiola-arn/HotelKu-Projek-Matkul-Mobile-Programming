HotelKu

HotelKu merupakan sistem aplikasi reservasi hotel berbasis mobile yang dikembangkan untuk memenuhi kebutuhan pemesanan akomodasi secara efisien dan real-time. Proyek ini mengimplementasikan arsitektur Client-Server dengan Flutter sebagai frontend dan PHP Native sebagai RESTful API Service.

Tim Pengembang
| NIM      | Nama Mahasiswa        | Peran (Role)                                      |
| 241712059| Febiola Kristin Aruan | Project Manager & Core Mobile Developer           |
| 241712070| Rael Gilbert Manurung | Backend Engineer & Database Administrator         |
| 241712052| Vaidon Selo Sinambela | Frontend Developer (Home & Hotel Discovery)       |
| 241712051| Nadya Lahfah          | Frontend Developer (User Profile & Booking System)|
| 241712057| Elaine Keisha Pasaribu| Frontend Developer (Admin Dashboard)              |


Arsitektur Sistem:
Aplikasi ini dibangun menggunakan teknologi berikut:
* Mobile Framework: Flutter SDK (Dart)
* Backend Service : PHP Native (version 8.0+)
* Database        : MySQL / MariaDB
* Architectural Pattern : MVVM (Model-View-ViewModel) via Provider State Management
* API Protocol          : REST (Representational State Transfer) with JSON format


Modul & Fungsionalitas
1.Client Side (Mobile App)
Authentication System: Dukungan login multi-role (Customer & Hotel Admin).
Hotel Discovery      : Algoritma pencarian hotel berdasarkan lokasi dan filter harga.
Booking Engine       : Sistem reservasi kamar dengan validasi ketersediaan real-time.
User Dashboard       : Manajemen profil, riwayat transaksi, dan daftar favorit.


2.Admin Side (Hotel Management)
Property Management  : CRUD (*Create, Read, Update, Delete*) data hotel dan fasilitas.
Sales Monitoring     : Dashboard analitik untuk memantau performa penjualan dan okupansi.
Guest Control        : Verifikasi kedatangan tamu dan manajemen status check-in/out.


3.Panduan Implementasi (Deployment)
Untuk menjalankan proyek ini pada lingkungan pengembangan lokal (Local Environment), ikuti instruksi teknis berikut:
Konfigurasi Backend & Database
1.  Pastikan Apache Web Server dan MySQL Database telah aktif (Disarankan menggunakan XAMPP/WAMP).
2.  Letakkan direktori proyek `hotelku` ke dalam root directory server (`htdocs`).
3.  Akses phpMyAdmin dan buat database baru dengan skema `hotelku`.
4.  Lakukan import skema database menggunakan file `database.sql` yang tersedia pada direktori root proyek.

4.Konfigurasi Endpoint Mobile
Agar aplikasi mobile dapat berkomunikasi dengan server lokal, konfigurasi Base URL diperlukan.
1.  Identifikasi IPv4 Address host machine melalui terminal (`ipconfig` pada Windows atau `ifconfig` pada Unix-based).
2.  Sesuaikan konstanta API pada file `lib/utils/constants.dart`:

```dart
class ApiConstants {
  // Format: http://<IP_ADDRESS_ANDA>/hotelku/php_api
  static const String baseUrl = 'http://192.168.1.XX/hotelku/php_api';
}
```

5.Eksekusi Aplikasi
Jalankan perintah berikut pada terminal direktori proyek:

```bash
# Mengunduh dependensi paket
flutter pub get

# Menjalankan aplikasi (Debug Mode)
flutter run
```

Dokumen ini kami susun sebagai bagian dari Laporan Tugas Akhir Mata Kuliah Mobile Programming.
