# 🚀 Cara Menjalankan Habitual Mobile

## ⚡ Quick Start

### Di Emulator:
```bash
cd "D:\Doc\File Aa\Aplikasi\Habitual Mobile\Kiro\habitual_mobile"
flutter clean
flutter pub get
flutter emulators --launch Medium_Phone_API_36.0
flutter run
```

### Di Perangkat Fisik (PENTING - BACA SEMUA):

#### Langkah 1: Setup Perangkat
1. **Aktifkan Developer Options**
   - Settings → About Phone
   - Tap "Build Number" 7 kali

2. **Aktifkan USB Debugging**
   - Settings → Developer Options
   - USB Debugging → ON
   - Stay Awake → ON (optional)

3. **Hubungkan dengan Kabel USB**
   - Gunakan kabel data (bukan hanya charging)
   - Pilih "File Transfer" mode
   - Izinkan USB debugging saat popup muncul

#### Langkah 2: Verifikasi Koneksi
```bash
cd "D:\Doc\File Aa\Aplikasi\Habitual Mobile\Kiro\habitual_mobile"
adb devices
# Harus muncul device ID dengan status "device"
```

#### Langkah 3: Uninstall App Lama (WAJIB!)
```bash
adb uninstall com.example.habitual_mobile
```

#### Langkah 4: Clean Build
```bash
flutter clean
flutter pub get
```

#### Langkah 5: Run App
```bash
# Untuk debug (dengan hot reload)
flutter run

# Atau untuk release (lebih stabil, recommended)
flutter run --release
```

## 🐛 Jika App Crash (Keluar Sendiri)

### Solusi 1: Lihat Log Error
```bash
# Jalankan script ini untuk lihat log:
check_crash_log.bat

# Atau manual:
adb logcat | findstr "flutter error crash"
```

### Solusi 2: Full Clean & Rebuild
```bash
# 1. Uninstall app
adb uninstall com.example.habitual_mobile

# 2. Clean project
flutter clean
cd android
gradlew clean
cd ..

# 3. Rebuild
flutter pub get
flutter run --release
```

### Solusi 3: Clear App Data
```bash
# Clear data tanpa uninstall
adb shell pm clear com.example.habitual_mobile
flutter run
```

### Solusi 4: Restart Device
```bash
# Restart ponsel
# Hubungkan ulang
# Run lagi
```

## ⚠️ PENTING!

### Jangan Lakukan:
- ❌ Hot restart (R) saat ada error native
- ❌ Run tanpa uninstall app lama setelah perubahan native
- ❌ Skip flutter clean setelah error

### Lakukan:
- ✅ Uninstall app lama sebelum install baru
- ✅ Flutter clean sebelum run
- ✅ Gunakan --release untuk testing di device
- ✅ Cek log jika crash

## 📱 Setup Perangkat Fisik Detail

### 1. Aktifkan Developer Options
```
Settings → About Phone → Tap "Build Number" 7x
```

### 2. Aktifkan USB Debugging
```
Settings → Developer Options → USB Debugging (ON)
```

### 3. Hubungkan & Verifikasi
```bash
adb devices
# Output: [device-id]    device
```

### 4. Jika Device Tidak Muncul
```bash
# Restart ADB
adb kill-server
adb start-server
adb devices

# Atau:
# - Cabut dan colok ulang kabel
# - Ganti kabel USB
# - Ganti port USB
# - Restart ponsel
```

## 🎯 Fitur Aplikasi

- ✅ Tambah/Edit/Hapus Kebiasaan
- ✅ Sistem Streak (hari berturut-turut)
- ✅ Kategori dengan Ikon & Warna
- ✅ Statistik & Pie Chart
- ✅ Arsip Kebiasaan
- ✅ Dark Mode
- ✅ Template Kebiasaan
- ✅ Backup & Restore

## 🔍 Monitoring & Debugging

### Lihat Log Real-time
```bash
# Terminal 1: Run app
flutter run

# Terminal 2: Monitor logs
adb logcat -s flutter
```

### Save Log ke File
```bash
adb logcat > app_log.txt
```

### Check Memory Usage
```bash
adb shell dumpsys meminfo com.example.habitual_mobile
```

## 📚 Dokumentasi Lengkap

- `CRASH_FIX.md` - Solusi lengkap untuk crash
- `PATH_PROVIDER_ERROR_FIX.md` - Fix error path provider
- `PHYSICAL_DEVICE_FIX.md` - Setup perangkat fisik
- `PANDUAN_LENGKAP.md` - Panduan lengkap A-Z
- `RINGKASAN_PERBAIKAN.md` - Ringkasan semua perbaikan

## 🆘 Troubleshooting Cepat

| Masalah | Solusi |
|---------|--------|
| Device tidak terdeteksi | `adb kill-server` → `adb start-server` |
| App crash saat launch | Uninstall → Clean → Run release |
| Path provider error | `flutter clean` → `flutter run` |
| Build error | `flutter clean` → `flutter pub get` |
| App keluar sendiri | Lihat `CRASH_FIX.md` |

## ✅ Checklist Sebelum Run

- [ ] USB Debugging aktif
- [ ] Device terhubung (`adb devices` menunjukkan device)
- [ ] App lama sudah di-uninstall
- [ ] Flutter clean sudah dijalankan
- [ ] Dependencies sudah di-get (`flutter pub get`)

---
**Status**: ✅ Siap digunakan dengan perbaikan crash!
**Versi**: 1.0.0

