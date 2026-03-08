# ⚠️ INSTRUKSI PENTING - WAJIB DIBACA!

## 🎯 Masalah yang Sudah Diperbaiki

1. ✅ **Aplikasi tidak bisa dijalankan di perangkat fisik** - FIXED
2. ✅ **Path Provider Error** - FIXED  
3. ✅ **Aplikasi crash/keluar sendiri** - FIXED
4. ✅ **R8 Error (Missing Play Core classes)** - FIXED

## 🚀 CARA MENJALANKAN DI PERANGKAT FISIK

### LANGKAH WAJIB (JANGAN DILEWATI!):

#### 1. Setup Perangkat Android
```
a. Settings → About Phone → Tap "Build Number" 7x
b. Settings → Developer Options → USB Debugging (ON)
c. Hubungkan dengan kabel USB (kabel DATA, bukan hanya charging)
d. Izinkan USB debugging saat popup muncul
```

#### 2. Verifikasi Koneksi
```bash
cd "D:\Doc\File Aa\Aplikasi\Habitual Mobile\Kiro\habitual_mobile"
adb devices
```
**Harus muncul**: `[device-id]    device`

**Jika tidak muncul**:
```bash
adb kill-server
adb start-server
adb devices
```

#### 3. Uninstall App Lama (WAJIB!)
```bash
adb uninstall com.example.habitual_mobile
```
**PENTING**: Ini wajib dilakukan setiap kali ada perubahan native code!

#### 4. Clean Build (WAJIB!)
```bash
flutter clean

# Clean Gradle juga (untuk fix R8 error)
cd android
gradlew clean
cd ..

# Get dependencies
flutter pub get
```

#### 5. Run Aplikasi
```bash
# Untuk release (RECOMMENDED untuk device)
flutter run --release

# Atau untuk debug
flutter run
```

## 🐛 JIKA APLIKASI CRASH (Keluar Sendiri)

### Solusi Cepat:
```bash
# 1. Uninstall
adb uninstall com.example.habitual_mobile

# 2. Clean
flutter clean
cd android
gradlew clean
cd ..

# 3. Get dependencies
flutter pub get

# 4. Run release
flutter run --release
```

### Lihat Log Error:
```bash
# Cara 1: Double click file ini
check_crash_log.bat

# Cara 2: Manual
adb logcat | findstr "flutter error crash fatal"

# Cara 3: Save ke file
adb logcat > crash_log.txt
```

## ⚠️ ATURAN PENTING

### ❌ JANGAN LAKUKAN:
1. Hot restart (tekan R) saat ada error native
2. Run tanpa uninstall app lama setelah perubahan native
3. Skip `flutter clean` setelah error
4. Gunakan kabel USB yang hanya untuk charging

### ✅ HARUS LAKUKAN:
1. Uninstall app lama sebelum install baru
2. `flutter clean` sebelum run
3. Gunakan `--release` untuk testing di device
4. Cek log jika crash
5. Gunakan kabel USB data

## 📋 Checklist Sebelum Run

Pastikan semua ini sudah dilakukan:

- [ ] USB Debugging aktif di ponsel
- [ ] Device terhubung (cek dengan `adb devices`)
- [ ] App lama sudah di-uninstall
- [ ] `flutter clean` sudah dijalankan
- [ ] `flutter pub get` sudah dijalankan
- [ ] Menggunakan kabel USB data (bukan hanya charging)

## 🔧 Perbaikan yang Diterapkan

### 1. MultiDex Configuration
- Custom Application class (`HabitualApplication.kt`)
- Proper MultiDex initialization
- ABI filters untuk kompatibilitas

### 2. Build Configuration
- minSdk = 21 (Android 5.0+)
- targetSdk = 34 (stable)
- multiDexEnabled = true
- extractNativeLibs = true

### 3. Error Handling
- runZonedGuarded untuk catch all errors
- Enhanced logging
- Explicit path initialization
- Lock orientation untuk stabilitas

### 4. AndroidManifest
- Custom Application class
- Required permissions
- Extract native libs

## 📱 Minimum Requirements

- **Android Version**: 5.0 (Lollipop) atau lebih tinggi
- **RAM**: 2GB minimum
- **Storage**: 100MB free space
- **Kabel**: USB data (bukan hanya charging)

## 🆘 Troubleshooting

### Device Tidak Terdeteksi
```bash
adb kill-server
adb start-server
adb devices
```
Jika masih tidak muncul:
- Cabut dan colok ulang kabel
- Ganti kabel USB
- Ganti port USB di komputer
- Restart ponsel
- Revoke USB debugging authorization di Developer Options

### App Crash Immediately
```bash
# Full clean
adb uninstall com.example.habitual_mobile
flutter clean
cd android
gradlew clean
cd ..
flutter pub get
flutter run --release
```

### Path Provider Error
```bash
# Stop app (Ctrl+C)
flutter clean
flutter pub get
flutter run
# JANGAN hot restart!
```

### Build Error
```bash
flutter clean
flutter pub get
cd android
gradlew clean
cd ..
flutter run
```

### R8 Error (Missing Play Core)
```bash
# Sudah diperbaiki dengan disable minify
# Jika masih error:
flutter clean
cd android
gradlew clean
cd ..
flutter pub get
flutter run --release
```

## 📚 Dokumentasi Lengkap

Untuk informasi lebih detail, baca:

1. **CARA_MENJALANKAN.md** - Panduan lengkap cara menjalankan
2. **R8_ERROR_FIX.md** - Solusi R8 error (Missing Play Core)
3. **CRASH_FIX.md** - Solusi lengkap untuk crash
4. **PATH_PROVIDER_ERROR_FIX.md** - Fix error path provider
5. **PHYSICAL_DEVICE_FIX.md** - Setup perangkat fisik detail
6. **PANDUAN_LENGKAP.md** - Panduan lengkap A-Z
7. **RINGKASAN_PERBAIKAN.md** - Ringkasan semua perbaikan

## ✅ Verifikasi Sukses

Aplikasi berhasil jika:
- ✅ App launch tanpa crash
- ✅ Bisa tambah habit
- ✅ Bisa mark habit complete
- ✅ Bisa buka Statistics
- ✅ Bisa buka Settings
- ✅ Data tersimpan setelah restart
- ✅ Tidak crash saat rotate screen

## 🎯 Next Steps Setelah Berhasil

1. Test semua fitur aplikasi
2. Tambah beberapa habits
3. Test backup & restore
4. Test dark mode
5. Kumpulkan feedback

---

## 📞 Jika Masih Ada Masalah

Kumpulkan informasi berikut:

```bash
# Device info
adb shell getprop ro.build.version.release  # Android version
adb shell getprop ro.product.model          # Device model

# Save log
adb logcat -d > full_log.txt
```

Lalu share:
- Device model
- Android version
- File full_log.txt
- Kapan crash terjadi (saat launch, saat buka fitur tertentu, dll)

---

**Status**: 🔧 Perbaikan lengkap diterapkan
**Versi**: 1.0.0
**Tanggal**: 24 Februari 2026

**INGAT**: Selalu uninstall app lama dan flutter clean sebelum run!
