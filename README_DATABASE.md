# Hotel Booking App - Database Setup Guide

## 📋 Daftar Isi
- [Tentang Database](#tentang-database)
- [Setup JSON Server](#setup-json-server)
- [API Endpoints](#api-endpoints)
- [Sample Data](#sample-data)
- [Testing API](#testing-api)

---

## Tentang Database

Database ini menggunakan format JSON dan dijalankan menggunakan **JSON Server**, yang menyediakan REST API lengkap tanpa perlu coding backend.

### Struktur Database

Database terdiri dari 5 collections:
1. **users** - Data pengguna aplikasi
2. **hotels** - Data hotel dengan detail lengkap
3. **bookings** - Data pemesanan hotel
4. **favorites** - Data hotel favorit user
5. **reviews** - Data review hotel dari user

---

## Setup JSON Server

### Prasyarat
- Node.js (versi 14 atau lebih baru)
- npm (biasanya sudah terinstall bersama Node.js)

### Langkah 1: Install Node.js

Jika belum punya Node.js, download dan install dari:
- **Website**: https://nodejs.org/
- Pilih versi **LTS (Long Term Support)**
- Install dengan pengaturan default

Verify instalasi:
```bash
node --version
npm --version
```

### Langkah 2: Install JSON Server

Buka Command Prompt atau PowerShell, lalu jalankan:

```bash
npm install -g json-server
```

Flag `-g` artinya install secara global, sehingga bisa digunakan di mana saja.

Verify instalasi:
```bash
json-server --version
```

### Langkah 3: Jalankan JSON Server

Navigate ke folder project:
```bash
cd "D:\src\sambung database dan flutter\Moprorendra\mopro_project"
```

Jalankan server:
```bash
json-server --watch db.json --port 3000
```

**Penjelasan:**
- `--watch db.json` - file database yang akan digunakan
- `--port 3000` - server akan berjalan di port 3000

Server akan berjalan di: `http://localhost:3000`

### Langkah 4: Test di Browser

Buka browser dan akses:
```
http://localhost:3000
```

Anda akan melihat halaman home JSON Server dengan daftar endpoints.

---

## API Endpoints

JSON Server otomatis membuat REST API endpoints untuk setiap collection:

### Users
- `GET /users` - Get all users
- `GET /users/:id` - Get user by ID
- `POST /users` - Create new user
- `PUT /users/:id` - Update user
- `DELETE /users/:id` - Delete user

### Hotels
- `GET /hotels` - Get all hotels
- `GET /hotels/:id` - Get hotel by ID
- `GET /hotels?city=Jakarta` - Filter by city
- `GET /hotels?rating_gte=4.5` - Filter by rating >= 4.5
- `GET /hotels?price_per_night_lte=1000000` - Filter by price <= 1000000
- `GET /hotels?q=Bali` - Search (full-text search)

### Bookings
- `GET /bookings` - Get all bookings
- `GET /bookings/:id` - Get booking by ID
- `GET /bookings?user_id=1` - Get bookings by user
- `GET /bookings?status=confirmed` - Filter by status
- `POST /bookings` - Create new booking
- `PATCH /bookings/:id` - Update booking (partial)
- `DELETE /bookings/:id` - Delete booking

### Favorites
- `GET /favorites` - Get all favorites
- `GET /favorites?user_id=1` - Get favorites by user
- `POST /favorites` - Add to favorites
- `DELETE /favorites/:id` - Remove from favorites

### Reviews
- `GET /reviews` - Get all reviews
- `GET /reviews?hotel_id=1` - Get reviews by hotel
- `POST /reviews` - Create new review
- `DELETE /reviews/:id` - Delete review

### Advanced Queries

**Pagination:**
```
GET /hotels?_page=1&_limit=10
```

**Sorting:**
```
GET /hotels?_sort=price_per_night&_order=asc
```

**Relations (Embed):**
```
GET /hotels/1?_embed=reviews
```

**Multiple Filters:**
```
GET /hotels?city=Jakarta&rating_gte=4.5&price_per_night_lte=2000000
```

---

## Sample Data

### Sample Users
```json
{
  "email": "ahmad@example.com",
  "password": "password123"
}
```

```json
{
  "email": "siti@example.com",
  "password": "password123"
}
```

### Sample Hotels
- **Grand Hotel Jakarta** - Rp 1.500.000/malam
- **Bali Beach Resort** - Rp 2.000.000/malam
- **Bandung Mountain Lodge** - Rp 800.000/malam
- **Surabaya Business Hotel** - Rp 1.000.000/malam
- **Yogyakarta Heritage Hotel** - Rp 900.000/malam
- **Lombok Sunset Villa** - Rp 2.500.000/malam

---

## Testing API

### Menggunakan Browser

Buka browser dan test endpoints berikut:

1. **Get all hotels:**
   ```
   http://localhost:3000/hotels
   ```

2. **Get hotel by ID:**
   ```
   http://localhost:3000/hotels/1
   ```

3. **Search hotels:**
   ```
   http://localhost:3000/hotels?q=Bali
   ```

4. **Filter by city:**
   ```
   http://localhost:3000/hotels?city=Jakarta
   ```

### Menggunakan Postman atau Thunder Client

Untuk testing POST, PUT, DELETE requests, gunakan tools seperti:
- **Postman** (https://www.postman.com/)
- **Thunder Client** (VS Code extension)
- **Insomnia** (https://insomnia.rest/)

**Contoh: Create Booking (POST)**

Endpoint: `POST http://localhost:3000/bookings`

Headers:
```
Content-Type: application/json
```

Body:
```json
{
  "user_id": "1",
  "hotel_id": "1",
  "hotel_name": "Grand Hotel Jakarta",
  "room_type": "Deluxe Room",
  "check_in": "2025-12-20",
  "check_out": "2025-12-22",
  "total_nights": 2,
  "total_price": 3000000,
  "status": "pending",
  "booking_date": "2025-12-04T13:59:06+07:00",
  "guest_name": "Ahmad Rizki",
  "guest_phone": "081234567890",
  "special_request": ""
}
```

---

## Menggunakan di Flutter

### Setup API Base URL

Buat file `lib/utils/constants.dart`:

```dart
class ApiConstants {
  // Untuk emulator Android
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  // Untuk iOS Simulator
  // static const String baseUrl = 'http://localhost:3000';
  
  // Untuk physical device (ganti dengan IP komputer Anda)
  // static const String baseUrl = 'http://192.168.1.100:3000';
}
```

### Cara Mendapatkan IP Komputer

**Windows:**
```bash
ipconfig
```
Cari "IPv4 Address" di bagian WiFi atau Ethernet adapter.

**macOS/Linux:**
```bash
ifconfig
```

### Contoh API Call di Flutter

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Hotel>> fetchHotels() async {
  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/hotels'),
  );

  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    return data.map((json) => Hotel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load hotels');
  }
}
```

---

## Tips & Troubleshooting

### Server Tidak Bisa Diakses dari Device

1. Pastikan komputer dan device di network WiFi yang sama
2. Disable firewall sementara atau allow port 3000
3. Gunakan IP address komputer, bukan `localhost`

### Port 3000 Sudah Digunakan

Gunakan port lain:
```bash
json-server --watch db.json --port 3001
```

### Data Tidak Tersimpan Setelah Restart

JSON Server otomatis save perubahan ke `db.json`. Jika tidak tersimpan:
- Pastikan file `db.json` tidak read-only
- Pastikan ada write permission di folder

### CORS Error

JSON Server sudah enable CORS by default. Jika masih error, jalankan dengan:
```bash
json-server --watch db.json --port 3000 --middlewares ./middleware.js
```

---

## Deployment (Optional)

Untuk deploy JSON Server agar bisa diakses online:

### Option 1: Render.com (Free)
1. Upload `db.json` ke GitHub repository
2. Deploy di Render.com sebagai Web Service
3. Command: `json-server --watch db.json --port $PORT --host 0.0.0.0`

### Option 2: Railway.app (Free)
1. Upload project ke GitHub
2. Connect repository ke Railway
3. Deploy otomatis

### Option 3: Glitch.com (Free)
1. Import project ke Glitch
2. Setup `package.json` dengan json-server
3. Auto-deploy

---

## Resources

- **JSON Server Documentation**: https://github.com/typicode/json-server
- **Node.js Download**: https://nodejs.org/
- **Postman**: https://www.postman.com/
- **Thunder Client**: https://www.thunderclient.com/

---

**Selamat mencoba! 🚀**
