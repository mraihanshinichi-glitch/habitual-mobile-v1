# 🎉 Fitur Baru - Habitual Mobile

## ✅ Fitur yang Ditambahkan

### 1. 🔍 Pencarian Kebiasaan

**Lokasi**: Home Page

**Fitur**:
- Search bar di bagian atas daftar kebiasaan
- Pencarian real-time saat mengetik
- Mencari berdasarkan:
  - Judul kebiasaan
  - Deskripsi kebiasaan
  - Nama kategori
- Tombol clear (X) untuk menghapus pencarian
- Tampilan "Tidak ada hasil" jika tidak ditemukan

**Cara Menggunakan**:
1. Buka halaman Home
2. Ketik di search bar
3. Hasil akan difilter secara otomatis
4. Tap X untuk clear pencarian

---

### 2. 🔥 Streak Pengguna (Global Streak)

**Lokasi**: Home Page (header)

**Fitur**:
- Streak bertambah saat semua kebiasaan selesai dalam satu hari
- Streak berkurang/reset saat ada kebiasaan yang tidak selesai
- Tampilan streak di header dengan ikon api
- Longest streak tersimpan
- Notifikasi milestone streak

**Cara Kerja**:
- **Streak +1**: Saat semua kebiasaan hari ini selesai DAN kemarin juga selesai
- **Streak Reset**: Saat ada kebiasaan yang tidak selesai dalam satu hari
- **Streak Mulai**: Dimulai dari 1 saat pertama kali semua kebiasaan selesai

**Milestone Notifikasi**:
- 3 hari: "Hebat! Anda telah mencapai streak 3 hari! 🎉"
- 7 hari: "Luar biasa! Streak 7 hari tercapai! Satu minggu penuh! 🌟"
- 14 hari: "Fantastis! Streak 14 hari! Dua minggu konsisten! 💪"
- 30 hari: "Menakjubkan! Streak 30 hari! Satu bulan penuh! 🏆"
- 50 hari: "Luar biasa! Streak 50 hari! Anda adalah juara! 👑"
- 100 hari: "LEGENDARIS! Streak 100 hari! Anda adalah master kebiasaan! 🎖️"
- Setiap 10 hari: "Keren! Streak X hari! Terus pertahankan! 🔥"

**Notifikasi Reset**:
- "💔 Streak Reset - Streak Anda telah direset. Jangan menyerah, mulai lagi hari ini!"

---

### 3. 🔔 Notifikasi dan Pengingat

**Fitur**:

#### A. Pengingat Harian untuk Kebiasaan
- Set waktu pengingat untuk setiap kebiasaan
- Notifikasi muncul setiap hari pada waktu yang ditentukan
- Bisa diatur saat membuat atau edit kebiasaan

**Cara Menggunakan**:
1. Tambah/Edit kebiasaan
2. Aktifkan "Pengingat"
3. Pilih waktu pengingat
4. Save
5. Notifikasi akan muncul setiap hari pada waktu tersebut

#### B. Notifikasi Streak Milestone
- Otomatis muncul saat mencapai milestone tertentu
- Milestone: 3, 7, 14, 30, 50, 100 hari, dan setiap kelipatan 10

#### C. Notifikasi Streak Reset
- Otomatis muncul saat streak direset
- Memberikan motivasi untuk mulai lagi

**Permissions Required**:
- Android 13+: Notification permission
- Android 12+: Exact alarm permission

---

## 🛠️ Perubahan Teknis

### File Baru:
1. `lib/shared/models/user_streak.dart` - Model untuk streak pengguna
2. `lib/shared/models/user_streak.g.dart` - Generated adapter
3. `lib/shared/repositories/user_streak_repository.dart` - Repository untuk streak
4. `lib/shared/providers/user_streak_provider.dart` - State management untuk streak

### File Diubah:
1. `lib/features/home/home_page.dart` - Tambah search bar dan tampilan streak
2. `lib/shared/providers/habit_provider.dart` - Integrasi dengan user streak
3. `lib/shared/services/notification_service.dart` - Implementasi lengkap notifikasi
4. `lib/core/database/database_service.dart` - Tambah user_streak box
5. `android/app/src/main/AndroidManifest.xml` - Tambah notification permissions
6. `pubspec.yaml` - Tambah dependencies notifikasi

### Dependencies Baru:
- `flutter_local_notifications: ^17.0.0`
- `timezone: ^0.9.2`

---

## 📱 Cara Menjalankan Setelah Update

### Langkah 1: Clean & Get Dependencies
```bash
cd "D:\Doc\File Aa\Aplikasi\Habitual Mobile\Kiro\habitual_mobile"
flutter clean
flutter pub get
```

### Langkah 2: Generate Adapters
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Langkah 3: Uninstall App Lama
```bash
adb uninstall com.example.habitual_mobile
```

### Langkah 4: Run
```bash
flutter run --release
```

---

## 🎯 Testing Checklist

### Pencarian:
- [ ] Search bar muncul di Home
- [ ] Pencarian bekerja saat mengetik
- [ ] Hasil difilter dengan benar
- [ ] Tombol clear berfungsi
- [ ] Tampilan "Tidak ada hasil" muncul

### Streak Pengguna:
- [ ] Streak ditampilkan di header Home
- [ ] Streak bertambah saat semua habit selesai
- [ ] Streak reset saat ada habit tidak selesai
- [ ] Notifikasi milestone muncul
- [ ] Notifikasi reset muncul

### Notifikasi:
- [ ] Permission notifikasi diminta
- [ ] Pengingat harian bisa diset
- [ ] Notifikasi muncul pada waktu yang ditentukan
- [ ] Notifikasi streak milestone muncul
- [ ] Notifikasi streak reset muncul

---

## ⚠️ Catatan Penting

### Notifikasi di Android 13+:
- Aplikasi akan meminta permission notifikasi saat pertama kali dibuka
- Jika ditolak, notifikasi tidak akan muncul
- Bisa diaktifkan manual di Settings → Apps → Habitual → Notifications

### Exact Alarm Permission:
- Diperlukan untuk notifikasi tepat waktu
- Otomatis diminta oleh aplikasi
- Jika tidak diberikan, notifikasi mungkin delay

### Streak Logic:
- Streak hanya dihitung untuk kebiasaan aktif (tidak diarsipkan)
- Streak dihitung per hari (00:00 - 23:59)
- Jika tidak ada kebiasaan, streak tidak berubah

---

## 🐛 Troubleshooting

### Notifikasi Tidak Muncul:
1. Cek permission di Settings → Apps → Habitual → Notifications
2. Pastikan "Exact alarm" permission diberikan
3. Cek battery optimization (disable untuk Habitual)
4. Restart aplikasi

### Streak Tidak Update:
1. Pastikan semua kebiasaan sudah di-complete
2. Tunggu hingga hari berikutnya untuk melihat perubahan
3. Cek log untuk error

### Search Tidak Bekerja:
1. Pastikan ada kebiasaan yang aktif
2. Coba ketik ulang
3. Restart aplikasi

---

## 📚 Dokumentasi Terkait

- `README.md` - Informasi aplikasi
- `MULAI_DISINI.md` - Quick start guide
- `INSTRUKSI_PENTING.md` - Panduan lengkap

---

**Status**: ✅ Fitur baru siap digunakan!
**Versi**: 1.1.0
**Tanggal**: 24 Februari 2026
