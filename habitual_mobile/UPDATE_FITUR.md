# 🎉 UPDATE FITUR - Habitual Mobile v1.1.0

## ✅ 3 Fitur Baru Berhasil Ditambahkan!

### 1. 🔍 Pencarian Kebiasaan
✅ Search bar di Home page
✅ Pencarian real-time
✅ Filter berdasarkan judul, deskripsi, dan kategori

### 2. 🔥 Streak Pengguna (Global Streak)
✅ Streak bertambah saat semua kebiasaan selesai
✅ Streak reset saat ada kebiasaan tidak selesai
✅ Tampilan streak di header Home
✅ Notifikasi milestone (3, 7, 14, 30, 50, 100 hari)
✅ Notifikasi saat streak reset

### 3. 🔔 Notifikasi dan Pengingat
✅ Pengingat harian untuk setiap kebiasaan
✅ Set waktu pengingat saat buat/edit kebiasaan
✅ Notifikasi streak milestone otomatis
✅ Notifikasi streak reset otomatis

---

## 🚀 CARA MENJALANKAN (PENTING!)

### Langkah 1: Clean & Install Dependencies
```bash
cd "D:\Doc\File Aa\Aplikasi\Habitual Mobile\Kiro\habitual_mobile"
flutter clean
flutter pub get
```

### Langkah 2: Generate Adapters
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Langkah 3: Uninstall App Lama (WAJIB!)
```bash
adb uninstall com.example.habitual_mobile
```

### Langkah 4: Clean Gradle
```bash
cd android
gradlew clean
cd ..
```

### Langkah 5: Run
```bash
flutter run --release
```

---

## 📱 Cara Menggunakan Fitur Baru

### Pencarian Kebiasaan:
1. Buka Home page
2. Ketik di search bar
3. Hasil akan difilter otomatis
4. Tap X untuk clear

### Streak Pengguna:
1. Lihat di header Home (ikon api + angka)
2. Complete semua kebiasaan hari ini
3. Streak akan bertambah besok jika semua selesai lagi
4. Notifikasi milestone akan muncul otomatis

### Notifikasi:
1. Saat pertama buka app, izinkan notifikasi
2. Tambah/Edit kebiasaan
3. Aktifkan "Pengingat"
4. Pilih waktu
5. Save
6. Notifikasi akan muncul setiap hari

---

## ⚠️ PENTING - Permissions

Aplikasi akan meminta 2 permissions:

### 1. Notification Permission (Android 13+)
- Diperlukan untuk semua notifikasi
- Muncul saat pertama buka app
- Jika ditolak, bisa diaktifkan di Settings

### 2. Exact Alarm Permission (Android 12+)
- Diperlukan untuk notifikasi tepat waktu
- Otomatis diminta
- Jika tidak diberikan, notifikasi mungkin delay

**Cara Manual Aktifkan**:
```
Settings → Apps → Habitual → Notifications → Allow
Settings → Apps → Habitual → Alarms & reminders → Allow
```

---

## 🎯 Testing Checklist

Setelah install, test fitur berikut:

### Pencarian:
- [ ] Search bar muncul di Home
- [ ] Ketik "olahraga" → hasil difilter
- [ ] Tap X → hasil kembali normal

### Streak:
- [ ] Streak ditampilkan di header (ikon api)
- [ ] Tambah 2-3 kebiasaan
- [ ] Complete semua kebiasaan
- [ ] Cek streak bertambah (mungkin perlu tunggu besok)

### Notifikasi:
- [ ] Permission diminta saat buka app
- [ ] Tambah kebiasaan dengan pengingat
- [ ] Set waktu (misal: 5 menit dari sekarang)
- [ ] Tunggu notifikasi muncul
- [ ] Complete semua kebiasaan untuk test notifikasi milestone

---

## 🐛 Troubleshooting

### Notifikasi Tidak Muncul:
```bash
# 1. Cek permission
Settings → Apps → Habitual → Notifications → ON

# 2. Cek battery optimization
Settings → Apps → Habitual → Battery → Unrestricted

# 3. Restart app
adb shell am force-stop com.example.habitual_mobile
flutter run --release
```

### Streak Tidak Update:
- Pastikan SEMUA kebiasaan aktif sudah di-complete
- Streak dihitung per hari (00:00 - 23:59)
- Tunggu hingga hari berikutnya untuk melihat perubahan

### Build Error:
```bash
flutter clean
cd android
gradlew clean
cd ..
flutter pub get
dart run build_runner build --delete-conflicting-outputs
adb uninstall com.example.habitual_mobile
flutter run --release
```

---

## 📚 Dokumentasi

- **FITUR_BARU.md** - Dokumentasi lengkap fitur baru
- **README.md** - Informasi aplikasi (updated)
- **MULAI_DISINI.md** - Quick start guide

---

## 🎉 Selamat!

Aplikasi Habitual Mobile sekarang memiliki:
- ✅ Pencarian kebiasaan
- ✅ Streak pengguna global
- ✅ Notifikasi lengkap

**Versi**: 1.1.0
**Status**: Siap digunakan!

Selamat menggunakan fitur baru! 🚀
