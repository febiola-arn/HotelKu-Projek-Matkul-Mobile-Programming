# 📢 PANDUAN UPLOAD TUGAS KELOMPOK (SISTEM ESTAFET)

Guys, biar codingan kita GAK RUSAK pas digabungin, tolong ikuti langkah-langkah ini sesuai urutan ya. Jangan balap-balapan! 🛑

**Konsepnya:** Kita antri. Si A selesai upload, baru Si B download terus upload bagian dia.

---

## 🛠️ Persiapan Awal (SEMUA WAJIB BACA)

1.  **Install Git**: Pastikan laptop kalian udah ada Git-nya.
2.  **Siapkan Folder Project**:
    *   Buka File Explorer, masuk ke folder `htdocs` di XAMPP (`C:\xampp\htdocs`).
    *   Klik kanan > **Git Bash Here**.
    *   Ketik: `git clone [LINK_REPO_GITHUB_KITA]`
    *   Sekarang kalian punya folder `hotelku`. Masuk ke folder itu.

---

## 🚦 URUTAN KERJA (JANGAN DIACAK!)

### 1️⃣ GILIRAN PERTAMA: Rael (Backend)
**Misi:** Upload Database & API.
1.  Buka folder project yang barusan di-clone.
2.  Copy folder `php_api` dan file `database.sql` (yang dikasih ketua) ke dalam folder project itu.
3.  Buka terminal/Git Bash di folder itu, ketik:
    ```bash
    git add .
    git commit -m "Upload Backend: API PHP dan Database"
    git push
    ```
4.  **Kabari di Grup:** "Backend sudah naik! Lanjut febiola."

---

### 2️⃣ GILIRAN KEDUA: febiola (Core System)
**Misi:** Upload Kerangka Flutter.
1.  Buka terminal, ketik: `git pull` (Wajib! Buat ngambil file si RG).
2.  Copy folder-folder inti Flutter (`lib`, `assets`, `pubspec.yaml`, dll) ke folder project.
3.  Ketik:
    ```bash
    git add .
    git commit -m "Upload Core Flutter: Main system & Auth"
    git push
    ```
4.  **Kabari di Grup:** "Kerangka aman! Lanjut vaidon.

---

### 3️⃣ GILIRAN KETIGA: vaidon(Fitur Home)
**Misi:** Upload Halaman Home & Detail Hotel.
1.  Buka terminal, ketik: `git pull` (Wajib! Biar dapet file Ketua).
2.  Copy folder `lib/screens/home` dan `lib/screens/hotel` (dari Ketua) ke tempat yang sama di laptopmu.
3.  Ketik:
    ```bash
    git add .
    git commit -m "Fitur: Halaman Home dan Hotel Detail"
    git push
    ```
4.  **Kabari di Grup:** "Home done! Lanjut nadya."

---

### 4️⃣ GILIRAN KEEMPAT: nadya (Fitur Profile)
**Misi:** Upload Halaman Profile & Booking.
1.  Buka terminal, ketik: `git pull` (Wajib!).
2.  Copy folder `lib/screens/profile` dan `lib/screens/bookings` ke tempat yang sesuai.
3.  Ketik:
    ```bash
    git add .
    git commit -m "Fitur: User Profile dan History Booking"
    git push
    ```
4.  **Kabari di Grup:** "Profile beres! Lanjut elaine."

---

### 5️⃣ GILIRAN TERAKHIR: elaine (Admin)
**Misi:** Upload Dashboard Admin.
1.  Buka terminal, ketik: `git pull` (Wajib!).
2.  Copy folder `lib/screens/admin` ke tempat yang sesuai.
3.  Ketik:
    ```bash
    git add .
    git commit -m "Fitur: Admin Dashboard"
    git push
    ```
4.  **Kabari di Grup:** "Admin selesai! Project Lengkap 🥳."

---

## ❓ FAQ (Kalo Ada Masalah)

**Q: Pas `git push` ada error merah-merah?**
A: Itu biasanya karena lupa `git pull`. Ketik `git pull` dulu, baru coba push lagi.

**Q: Pas `git pull` malah masuk ke layar aneh (Vim)?**
A: Tekan `:q!` terus Enter buat keluar. Atau tekan `Esc` terus `:wq` Enter kalau disuruh save merge.

**Q: Salah paste folder gimana?**
A: Hapus file yang salah, terus ulangi copy-paste yang benar. Jangan lupa `git add .` lagi.

**Fighting! 🚀**
