# HotelKu - Aplikasi Booking Hotel

Aplikasi mobile booking hotel yang dibuat dengan Flutter untuk tugas akhir Mata Kuliah Mobile Programming.

## 📱 Fitur Aplikasi

### Authentication
- ✅ Login dengan email dan password
- ✅ Register akun baru
- ✅ Auto-login dengan SharedPreferences
- ✅ Logout

### Hotel Management
- ✅ Daftar hotel dengan gambar dan informasi lengkap
- ✅ Search hotel berdasarkan nama atau kota
- ✅ Filter hotel berdasarkan kota
- ✅ Detail hotel dengan galeri foto
- ✅ Informasi fasilitas dan tipe kamar
- ✅ Rating dan review hotel

### Booking System
- ✅ Pilih tanggal check-in dan check-out
- ✅ Pilih tipe kamar
- ✅ Kalkulasi harga otomatis
- ✅ Form data tamu
- ✅ Konfirmasi booking
- ✅ Riwayat booking dengan status
- ✅ Batalkan booking

### Favorites
- ✅ Tambah hotel ke favorit
- ✅ Hapus dari favorit
- ✅ Lihat daftar favorit

### Profile
- ✅ Lihat informasi profil
- ✅ Edit profil (dalam pengembangan)
- ✅ Logout

## 🛠️ Teknologi yang Digunakan

- **Flutter**: Framework utama
- **Provider**: State management
- **HTTP**: API calls ke JSON Server
- **SharedPreferences**: Local storage untuk auth
- **Cached Network Image**: Image caching
- **Intl**: Formatting tanggal dan currency
- **Shimmer**: Loading skeleton
- **Flutter Rating Bar**: Rating display

## 📦 Struktur Project

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Data models
│   ├── user.dart
│   ├── hotel.dart
│   ├── booking.dart
│   ├── review.dart
│   └── favorite.dart
├── services/                 # API services
│   ├── api_service.dart
│   └── auth_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── hotel_provider.dart
│   ├── booking_provider.dart
│   ├── favorite_provider.dart
│   └── review_provider.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── home/
│   │   └── home_page.dart
│   ├── hotel/
│   │   ├── hotel_detail_page.dart
│   │   └── booking_page.dart
│   ├── bookings/
│   │   └── my_bookings_page.dart
│   └── profile/
│       └── profile_page.dart
├── widgets/                  # Reusable widgets
│   ├── hotel_card.dart
│   ├── loading_shimmer.dart
│   └── empty_state.dart
└── utils/                    # Utilities
    ├── constants.dart
    ├── helpers.dart
    └── app_theme.dart
```

## 🚀 Cara Menjalankan Aplikasi

### Prasyarat
1. Flutter SDK (versi 3.9.0 atau lebih baru)
2. Node.js dan npm (untuk JSON Server)
3. Android Studio / VS Code
4. Android Emulator / iOS Simulator / Physical Device

### Langkah 1: Install Dependencies

```bash
# Navigate ke folder project
cd mopro_project

# Install Flutter dependencies
flutter pub get
```

### Langkah 2: Setup JSON Server

```bash
# Install JSON Server (jika belum)
npm install -g json-server

# Jalankan JSON Server
json-server --watch db.json --port 3000
```

Server akan berjalan di `http://localhost:3000`

### Langkah 3: Konfigurasi API Base URL

Buka file `lib/utils/constants.dart` dan sesuaikan base URL:

```dart
// Untuk Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000';

// Untuk iOS Simulator
// static const String baseUrl = 'http://localhost:3000';

// Untuk Physical Device (ganti dengan IP komputer Anda)
// static const String baseUrl = 'http://192.168.1.100:3000';
```

**Cara mendapatkan IP komputer:**
- Windows: `ipconfig` di Command Prompt
- macOS/Linux: `ifconfig` di Terminal

### Langkah 4: Run Aplikasi

```bash
# Check devices
flutter devices

# Run di emulator/device
flutter run
```

## 👤 Demo Account

Untuk testing, gunakan akun berikut:

**Email:** ahmad@example.com  
**Password:** password123

Atau buat akun baru melalui halaman Register.

## 📊 Data Sample

Database sudah dilengkapi dengan data sample:
- 3 users
- 6 hotels (Jakarta, Bali, Bandung, Surabaya, Yogyakarta, Lombok)
- Sample bookings
- Sample reviews
- Sample favorites

## 🐛 Troubleshooting

### Error: Connection refused
- Pastikan JSON Server sudah berjalan
- Periksa base URL di `constants.dart`
- Untuk physical device, pastikan device dan komputer di network WiFi yang sama

### Error: Packages not found
```bash
flutter clean
flutter pub get
```

### Error: Build failed
```bash
flutter doctor
# Fix issues yang muncul
```

## 📝 Catatan Pengembangan

### Fitur yang Sudah Diimplementasi
- ✅ Authentication (Login, Register, Logout)
- ✅ Hotel Listing dengan Search & Filter
- ✅ Hotel Detail dengan Review
- ✅ Booking System lengkap
- ✅ My Bookings dengan status
- ✅ Favorites
- ✅ Profile Management
- ✅ Loading States & Error Handling
- ✅ Responsive Design

### Fitur untuk Pengembangan Selanjutnya
- ⏳ Edit Profile
- ⏳ Payment Gateway
- ⏳ Push Notifications
- ⏳ Chat dengan Hotel
- ⏳ Maps Integration
- ⏳ Dark Mode

## 📄 Lisensi

Aplikasi ini dibuat untuk keperluan tugas akhir Mobile Programming.

## 👨‍💻 Developer

Dibuat dengan ❤️ untuk tugas akhir Mobile Programming

---

**Selamat mencoba! 🚀**
