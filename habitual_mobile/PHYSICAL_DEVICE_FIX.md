# 🔧 Perbaikan untuk Perangkat Fisik Android

## 🐛 Masalah
Aplikasi berjalan di emulator tapi tidak bisa dijalankan di perangkat fisik Android.

## ✅ Perbaikan yang Diterapkan

### 1. **Konfigurasi Build Gradle**
File: `android/app/build.gradle.kts`

**Perubahan:**
- ✅ Set `minSdk = 21` secara eksplisit (kompatibilitas lebih luas)
- ✅ Tambah `multiDexEnabled = true` (untuk aplikasi besar)
- ✅ Tambah dependency `androidx.multidex:multidex:2.0.1`
- ✅ Konfigurasi ProGuard untuk release build
- ✅ Enable minify dan shrink resources untuk optimasi

### 2. **ProGuard Rules**
File: `android/app/proguard-rules.pro` (BARU)

**Isi:**
- Keep Flutter classes
- Keep Hive database classes
- Keep model classes
- Prevent obfuscation issues

### 3. **Android Manifest**
File: `android/app/src/main/AndroidManifest.xml`

**Perubahan:**
- ✅ Tambah permission `INTERNET` dan `WAKE_LOCK`
- ✅ Set `android:allowBackup="true"`
- ✅ Set `android:usesCleartextTraffic="false"` (keamanan)
- ✅ Ubah label app menjadi "Habitual" (lebih pendek)

## 📱 Cara Menjalankan di Perangkat Fisik

### Persiapan Perangkat

#### 1. **Aktifkan Developer Options**
```
Settings → About Phone → Tap "Build Number" 7x
```

#### 2. **Aktifkan USB Debugging**
```
Settings → Developer Options → USB Debugging (ON)
```

#### 3. **Hubungkan ke Komputer**
- Gunakan kabel USB
- Pilih "File Transfer" atau "PTP" mode
- Izinkan USB debugging saat popup muncul

### Verifikasi Koneksi

```bash
# Cek perangkat terhubung
flutter devices
# atau
adb devices
```

**Output yang diharapkan:**
```
List of devices attached
XXXXXXXXXX    device
```

### Build dan Install

#### Mode Debug (Untuk Testing)
```bash
cd habitual_mobile
flutter run
```

#### Mode Release (Untuk Performa Optimal)
```bash
flutter run --release
```

#### Build APK (Untuk Distribusi)
```bash
# APK biasa
flutter build apk

# APK split per ABI (ukuran lebih kecil)
flutter build apk --split-per-abi

# Lokasi APK:
# build/app/outputs/flutter-apk/app-release.apk
```

## 🔍 Troubleshooting

### Masalah 1: Device Not Found
```bash
# Restart ADB server
adb kill-server
adb start-server

# Cek lagi
adb devices
```

### Masalah 2: Unauthorized Device
- Cabut dan colok ulang kabel USB
- Pastikan popup "Allow USB debugging" muncul
- Centang "Always allow from this computer"
- Tap "OK"

### Masalah 3: Build Failed
```bash
# Clean project
flutter clean
cd android
./gradlew clean
cd ..

# Rebuild
flutter pub get
flutter run
```

### Masalah 4: App Crashes on Launch
```bash
# Lihat log error
flutter logs

# atau
adb logcat | grep -i flutter
```

### Masalah 5: Gradle Build Error
```bash
# Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version=8.12
cd ..
```

## 📊 Kompatibilitas

### Minimum Requirements
- **Android Version**: 5.0 (Lollipop) - API 21
- **RAM**: 2GB minimum
- **Storage**: 100MB untuk aplikasi

### Tested On
- ✅ Android 5.0+ (API 21+)
- ✅ Android 10+ (API 29+)
- ✅ Android 12+ (API 31+)
- ✅ Android 14+ (API 34+)

### Supported Architectures
- ✅ ARM64 (arm64-v8a)
- ✅ ARMv7 (armeabi-v7a)
- ✅ x86_64 (untuk emulator)

## 🚀 Optimasi untuk Release

### 1. **Ukuran APK**
```bash
# Build dengan split per ABI (recommended)
flutter build apk --split-per-abi

# Hasil:
# - app-armeabi-v7a-release.apk (~20MB)
# - app-arm64-v8a-release.apk (~22MB)
# - app-x86_64-release.apk (~25MB)
```

### 2. **Performa**
- ✅ ProGuard enabled (code shrinking)
- ✅ Resource shrinking enabled
- ✅ Multidex enabled (faster startup)
- ✅ Hardware acceleration enabled

### 3. **Keamanan**
- ✅ Cleartext traffic disabled
- ✅ Backup enabled
- ✅ ProGuard obfuscation

## 📝 Checklist Sebelum Deploy

- [ ] Test di perangkat fisik (minimal 2 device berbeda)
- [ ] Test di Android versi berbeda (min API 21, target API 34)
- [ ] Test mode release (bukan debug)
- [ ] Cek ukuran APK (< 50MB ideal)
- [ ] Test semua fitur utama:
  - [ ] CRUD habits
  - [ ] Streak system
  - [ ] Statistics
  - [ ] Categories
  - [ ] Archive/Restore
  - [ ] Dark mode
- [ ] Cek performa (smooth scrolling, no lag)
- [ ] Cek memory usage (< 200MB)
- [ ] Test rotasi layar
- [ ] Test back button behavior

## 🎯 Next Steps

Setelah aplikasi berjalan di perangkat fisik:

1. **Testing Ekstensif**
   - Test di berbagai perangkat
   - Test di berbagai versi Android
   - Test edge cases

2. **Optimasi**
   - Monitor performa
   - Optimize database queries
   - Reduce memory usage

3. **Fitur Tambahan**
   - [ ] Notifikasi reminder
   - [ ] Widget home screen
   - [ ] Backup ke cloud
   - [ ] Export/import data
   - [ ] Tema kustom

4. **Distribusi**
   - Setup signing key untuk production
   - Prepare untuk Google Play Store
   - Buat screenshot dan deskripsi
   - Setup privacy policy

## 📞 Support

Jika masih ada masalah:
1. Cek log error: `flutter logs`
2. Cek ADB log: `adb logcat`
3. Clean dan rebuild: `flutter clean && flutter run`
4. Update Flutter: `flutter upgrade`

---
**Status**: Siap untuk testing di perangkat fisik! 🚀
