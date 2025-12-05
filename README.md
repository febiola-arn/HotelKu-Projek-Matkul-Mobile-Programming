# HotelKu - Projek UAS Mobile Programming

Halo! 👋
Ini adalah projek aplikasi booking hotel sederhana yang saya buat untuk memenuhi tugas akhir mata kuliah Mobile Programming di Semester 3. Aplikasi ini dibuat menggunakan Flutter dan backend-nya simulasi pakai JSON Server.

## Fitur-fitur Aplikasi
Aplikasi ini punya beberapa fitur utama:
*   **Login & Register**: Bisa buat akun baru dan login (datanya tersimpan).
*   **Daftar Hotel**: Bisa liat list hotel, lengkap sama gambar dan harganya.
*   **Search & Filter**: Bisa cari hotel berdasarkan nama atau filter berdasarkan kota.
*   **Booking**: Bisa pesen kamar, pilih tanggal check-in/out, dan liat total harganya.
*   **Favorit**: Bisa simpen hotel yang disuka ke menu favorit.
*   **History Booking**: Bisa liat riwayat pemesanan yang udah dibuat.

## Teknologi yang Dipakai
*   **Flutter**: Framework utamanya.
*   **Provider**: Buat ngatur state management-nya (biar rapi).
*   **HTTP**: Buat request data ke JSON Server.
*   **SharedPreferences**: Buat nyimpen sesi login biar gak logout sendiri pas aplikasi ditutup.
*   **JSON Server**: Buat pura-pura jadi backend API.

## Cara Jalanin Aplikasinya

Sebelum jalanin, pastiin udah install **Flutter** sama **Node.js** ya.

1.  **Clone atau Download** repo ini.
2.  Buka terminal di folder project, terus ketik:
    ```bash
    flutter pub get
    ```
    Tunggu sampe selesai download library-nya.

3.  **Siapin Backend-nya (JSON Server)**
    Ketik ini di terminal (bisa pake terminal bawaan VS Code):
    ```bash
    npm install -g json-server
    json-server --watch db.json --port 3000
    ```
    Nanti servernya jalan di `http://localhost:3000`.

4.  **Setting IP Address** (Penting!)
    Kalo mau run di emulator Android, biasanya IP nya `10.0.2.2`.
    Kalo run di HP asli, ganti pake IP laptop kamu (cek pake `ipconfig`).
    Setting-nya ada di file `lib/utils/constants.dart`.

5.  **Jalanin Aplikasi**
    Tinggal ketik:
    ```bash
    flutter run
    ```

## Akun Buat Ngetes
Kalo males daftar, bisa pake akun ini:
*   **Email**: ahmad@example.com
*   **Password**: password123

## Catatan
Kalo ada error kayak "Connection Refused", coba cek lagi JSON Server-nya udah jalan apa belum, atau IP address-nya udah bener belum.

---
*Dibuat untuk tugas kuliah. Jangan lupa kasih bintang ya kak! ⭐*
