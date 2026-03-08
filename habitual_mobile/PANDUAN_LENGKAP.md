# 📱 Panduan Lengkap - Habitual Mobile

## 🎯 Status Aplikasi

### ✅ Fitur yang Sudah Selesai
- ✅ CRUD Kebiasaan (Create, Read, Update, Delete)
- ✅ Sistem Streak (hitung hari berturut-turut)
- ✅ Kategori Kustom dengan ikon dan warna
- ✅ Statistik dengan Pie Chart
- ✅ Arsip Kebiasaan
- ✅ Dark Mode
- ✅ Template Kebiasaan (15+ template)
- ✅ Backup & Restore (sederhana)
- ✅ Timer untuk kebiasaan
- ✅ Database Hive (offline-first)

### 🔧 Perbaikan yang Sudah Diterapkan
- ✅ Konfigurasi Android untuk perangkat fisik
- ✅ MultiDex enabled
- ✅ MinSdk set ke 21 (Android 5.0+)
- ✅ Permissions yang diperlukan
- ✅ ProGuard rules untuk release build

## 🚀 Cara Menjalankan di Perangkat Fisik

### Langkah 1: Persiapan Perangkat Android

#### A. Aktifkan Developer Options
1. Buka **Settings** (Pengaturan)
2. Scroll ke bawah, pilih **About Phone** (Tentang Ponsel)
3. Cari **Build Number** (Nomor Build)
4. Tap **Build Number** sebanyak **7 kali**
5. Masukkan PIN/Password jika diminta
6. Akan muncul notifikasi "You are now a developer!"

#### B. Aktifkan USB Debugging
1. Kembali ke **Settings**
2. Cari dan buka **Developer Options** (Opsi Pengembang)
3. Scroll ke bawah, cari **USB Debugging**
4. Aktifkan **USB Debugging** (toggle ON)
5. Konfirmasi jika ada popup

#### C. Hubungkan ke Komputer
1. Gunakan kabel USB (pastikan kabel data, bukan hanya charging)
2. Colokkan ke komputer
3. Di ponsel, pilih mode **File Transfer** atau **PTP**
4. Akan muncul popup "Allow USB debugging?"
5. Centang "Always allow from this computer"
6. Tap **OK**

### Langkah 2: Verifikasi Koneksi

Buka Command Prompt atau PowerShell, jalankan:

```bash
cd "D:\Doc\File Aa\Aplikasi\Habitual Mobile\Kiro\habitual_mobile"
flutter devices
```

**Output yang diharapkan:**
```
Found 4 connected devices:
  [Nama Perangkat] (mobile) • [ID] • android-arm64 • Android [Versi]
  Windows (desktop) • windows • windows-x64 • Microsoft Windows
  Chrome (web) • chrome • web-javascript • Google Chrome
  Edge (web) • edge • web-javascript • Microsoft Edge
```

Jika perangkat tidak muncul, coba:
```bash
adb devices
```

Jika masih tidak muncul:
```bash
adb kill-server
adb start-server
adb devices
```

### Langkah 3: Build dan Install

#### Opsi A: Mode Debug (Untuk Testing)
```bash
flutter run
```

Atau pilih perangkat spesifik:
```bash
flutter run -d [device-id]
```

#### Opsi B: Mode Release (Performa Optimal)
```bash
flutter run --release
```

#### Opsi C: Build APK (Untuk Install Manual)
```bash
# Build APK
flutter build apk --release

# Lokasi file:
# build\app\outputs\flutter-apk\app-release.apk
```

Install manual via ADB:
```bash
adb install build\app\outputs\flutter-apk\app-release.apk
```

### Langkah 4: Testing Aplikasi

Setelah aplikasi terinstall, test fitur-fitur berikut:

#### 1. Home Page
- [ ] Lihat daftar kebiasaan (awalnya kosong)
- [ ] Tap tombol **+** untuk tambah kebiasaan
- [ ] Isi form dan simpan
- [ ] Centang checkbox untuk mark selesai
- [ ] Lihat streak bertambah (ikon api)

#### 2. Add/Edit Habit
- [ ] Tambah kebiasaan baru
- [ ] Pilih kategori dari dropdown
- [ ] Edit kebiasaan yang ada
- [ ] Arsipkan kebiasaan

#### 3. Statistics
- [ ] Lihat pie chart distribusi kategori
- [ ] Lihat summary cards (Total, Minggu, Bulan)
- [ ] Lihat detail per kategori

#### 4. Settings
- [ ] Kelola kategori (tambah, edit, hapus)
- [ ] Lihat kebiasaan terarsip
- [ ] Restore kebiasaan dari arsip
- [ ] Ganti tema (Light/Dark/System)
- [ ] Lihat template kebiasaan
- [ ] Backup & restore data

## 🐛 Troubleshooting

### Masalah 1: Perangkat Tidak Terdeteksi

**Solusi:**
```bash
# 1. Restart ADB
adb kill-server
adb start-server

# 2. Cek koneksi
adb devices

# 3. Jika masih tidak muncul, coba:
# - Cabut dan colok ulang kabel USB
# - Ganti kabel USB (pastikan kabel data)
# - Ganti port USB di komputer
# - Restart ponsel
# - Restart komputer
```

### Masalah 2: "Unauthorized" di ADB Devices

**Solusi:**
1. Cabut kabel USB
2. Di ponsel: Settings → Developer Options → Revoke USB debugging authorizations
3. Colok ulang kabel
4. Izinkan USB debugging lagi

### Masalah 3: Build Failed

**Solusi:**
```bash
# Clean project
flutter clean

# Clean Gradle
cd android
gradlew clean
cd ..

# Get dependencies
flutter pub get

# Build lagi
flutter run
```

### Masalah 4: App Crashes Saat Launch

**Solusi:**
```bash
# Lihat log error
flutter logs

# Atau gunakan ADB logcat
adb logcat | findstr "flutter"
```

**Error umum dan solusinya:**
- **Database error**: Uninstall app, install ulang
- **Permission error**: Cek AndroidManifest.xml
- **Memory error**: Enable multidex (sudah dilakukan)

### Masalah 5: Gradle Build Timeout

**Solusi:**
```bash
# Increase Gradle memory
# Edit: android/gradle.properties
# Tambahkan:
org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m
```

## 📋 Fitur yang Bisa Ditambahkan

### 1. Notifikasi Reminder ⏰
**Status**: Kode sudah ada tapi belum aktif

**Cara Mengaktifkan:**
1. Uncomment dependency di `pubspec.yaml`:
```yaml
flutter_local_notifications: ^17.0.0
timezone: ^0.9.2
```

2. Update `notification_service.dart`
3. Tambah permission di `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

### 2. Widget Home Screen 📱
**Benefit**: Lihat progress tanpa buka app

**Implementasi:**
- Gunakan package `home_widget`
- Buat widget layout di Android native
- Update widget saat habit completed

### 3. Cloud Backup ☁️
**Benefit**: Sync antar perangkat

**Opsi:**
- Firebase Storage
- Google Drive API
- Dropbox API

### 4. Export/Import Data 📤
**Benefit**: Share data atau backup manual

**Format:**
- JSON (sudah ada)
- CSV untuk Excel
- PDF untuk laporan

### 5. Gamification 🎮
**Fitur:**
- Achievement badges
- Level system
- Leaderboard (jika multi-user)
- Reward points

### 6. Analytics 📊
**Fitur:**
- Heatmap calendar
- Trend analysis
- Best/worst days
- Completion rate graph

### 7. Social Features 👥
**Fitur:**
- Share progress
- Challenge friends
- Community templates
- Motivational quotes

## 🎨 Customization Ideas

### 1. Tema Kustom
- Tambah lebih banyak color schemes
- Custom font options
- Icon pack selection

### 2. Habit Types
- Daily habits
- Weekly habits
- Monthly goals
- One-time tasks

### 3. Advanced Tracking
- Quantity tracking (e.g., 8 glasses of water)
- Duration tracking (e.g., 30 minutes exercise)
- Notes per completion
- Photo attachments

## 📦 Persiapan untuk Production

### 1. Setup Signing Key

Buat keystore untuk production:
```bash
keytool -genkey -v -keystore habitual-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias habitual
```

Edit `android/app/build.gradle.kts`:
```kotlin
signingConfigs {
    create("release") {
        storeFile = file("../../habitual-release-key.jks")
        storePassword = System.getenv("KEYSTORE_PASSWORD")
        keyAlias = "habitual"
        keyPassword = System.getenv("KEY_PASSWORD")
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

### 2. Update App Info

Edit `android/app/build.gradle.kts`:
```kotlin
defaultConfig {
    applicationId = "com.yourcompany.habitual"  // Ganti dengan ID unik
    versionCode = 1
    versionName = "1.0.0"
}
```

Edit `AndroidManifest.xml`:
```xml
<application
    android:label="Habitual"  // Nama app
    android:icon="@mipmap/ic_launcher">  // Icon app
```

### 3. Buat Icon App

Gunakan tool online atau Flutter package:
```bash
flutter pub add flutter_launcher_icons
```

Buat `flutter_launcher_icons.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/app_icon.png"
```

Generate:
```bash
flutter pub run flutter_launcher_icons
```

### 4. Build Release APK

```bash
# Build APK
flutter build apk --release --split-per-abi

# Hasil:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### 5. Build App Bundle (untuk Play Store)

```bash
flutter build appbundle --release

# Hasil:
# build/app/outputs/bundle/release/app-release.aab
```

## 📱 Distribusi

### Opsi 1: Google Play Store
1. Buat akun Google Play Developer ($25 one-time)
2. Upload app bundle (.aab)
3. Isi store listing (deskripsi, screenshot, dll)
4. Submit untuk review

### Opsi 2: Direct APK
1. Upload APK ke website/cloud storage
2. Share link download
3. User harus enable "Install from Unknown Sources"

### Opsi 3: Internal Testing
1. Share APK via email/WhatsApp
2. Install manual di perangkat tester
3. Kumpulkan feedback

## 🎯 Checklist Sebelum Release

### Functionality
- [ ] Semua fitur bekerja dengan baik
- [ ] Tidak ada crash atau error
- [ ] Data tersimpan dengan benar
- [ ] Backup/restore berfungsi

### Performance
- [ ] App launch < 3 detik
- [ ] Smooth scrolling (60 FPS)
- [ ] Memory usage < 200MB
- [ ] APK size < 50MB

### UI/UX
- [ ] Responsive di berbagai ukuran layar
- [ ] Dark mode berfungsi sempurna
- [ ] Animasi smooth
- [ ] Loading indicators jelas

### Testing
- [ ] Test di minimal 3 perangkat berbeda
- [ ] Test di Android 5.0 - 14
- [ ] Test rotasi layar
- [ ] Test back button behavior
- [ ] Test dengan data banyak (100+ habits)

### Legal
- [ ] Privacy policy (jika collect data)
- [ ] Terms of service
- [ ] Open source licenses
- [ ] Copyright notice

## 📞 Support & Resources

### Documentation
- Flutter: https://flutter.dev/docs
- Hive: https://docs.hivedb.dev
- Riverpod: https://riverpod.dev

### Community
- Flutter Discord
- Stack Overflow
- Reddit r/FlutterDev

### Tools
- Android Studio
- VS Code + Flutter extension
- Firebase Console (untuk analytics)

---

## 🎉 Kesimpulan

Aplikasi Habitual Mobile sudah **siap digunakan** dengan fitur-fitur utama yang lengkap. Perbaikan untuk perangkat fisik sudah diterapkan. 

**Next Steps:**
1. Test di perangkat fisik Anda
2. Kumpulkan feedback dari user
3. Tambahkan fitur sesuai kebutuhan
4. Siapkan untuk production release

**Selamat menggunakan Habitual Mobile! 🚀**
