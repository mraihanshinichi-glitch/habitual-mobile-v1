# 🔧 Perbaikan Crash di Perangkat Fisik

## 🐛 Masalah

Aplikasi keluar sendiri (crash) tanpa pesan error saat dijalankan di perangkat fisik Android.

## 🔍 Penyebab Umum Crash

1. **MultiDex tidak dikonfigurasi dengan benar**
2. **Native library tidak kompatibel dengan arsitektur device**
3. **Memory overflow saat inisialisasi**
4. **Permission tidak diberikan**
5. **Versi Android terlalu lama**
6. **Konflik library native**

## ✅ Perbaikan yang Diterapkan

### 1. **Application Class untuk MultiDex**

File baru: `android/app/src/main/kotlin/com/example/habitual_mobile/HabitualApplication.kt`

```kotlin
package com.example.habitual_mobile

import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDex
import android.content.Context

class HabitualApplication : FlutterApplication() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
```

**Benefit**: Memastikan MultiDex diinisialisasi dengan benar sebelum app start.

### 2. **Update AndroidManifest.xml**

```xml
<application
    android:name=".HabitualApplication"  <!-- Custom Application class -->
    android:extractNativeLibs="true">    <!-- Extract native libs -->
```

**Benefit**: 
- Menggunakan custom Application class
- Extract native libraries untuk kompatibilitas lebih baik

### 3. **Update build.gradle.kts**

```kotlin
defaultConfig {
    minSdk = 21  // Android 5.0+
    targetSdk = 34  // Stable version
    versionCode = 1
    versionName = "1.0.0"
    multiDexEnabled = true
    
    // Prevent crashes on older devices
    ndk {
        abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86_64"))
    }
}
```

**Benefit**:
- Set versi eksplisit (tidak dynamic)
- Filter ABI untuk arsitektur yang didukung
- Mencegah crash di device dengan arsitektur tidak didukung

### 4. **Enhanced Error Handling di main.dart**

```dart
void main() async {
  runZonedGuarded(() async {
    // App initialization...
  }, (error, stack) {
    print('FATAL ERROR: $error');
    print('STACK TRACE: $stack');
  });
}
```

**Benefit**:
- Catch semua uncaught errors
- Log error untuk debugging
- Lock orientation untuk stabilitas

## 🚀 Cara Menjalankan Setelah Perbaikan

### Langkah 1: Clean Build

```bash
cd "D:\Doc\File Aa\Aplikasi\Habitual Mobile\Kiro\habitual_mobile"
flutter clean
```

### Langkah 2: Get Dependencies

```bash
flutter pub get
```

### Langkah 3: Uninstall App Lama (Penting!)

```bash
adb uninstall com.example.habitual_mobile
```

### Langkah 4: Build & Install

```bash
# Untuk debug
flutter run

# Atau untuk release (lebih stabil)
flutter run --release
```

## 🔍 Cara Melihat Log Crash

### Opsi 1: Gunakan Script Batch (Windows)

```bash
# Double click file ini:
check_crash_log.bat
```

### Opsi 2: Manual dengan ADB

```bash
# Lihat semua log
adb logcat

# Filter Flutter logs
adb logcat | findstr "flutter"

# Filter error logs
adb logcat | findstr "error crash fatal"

# Save log ke file
adb logcat > crash_log.txt
```

### Opsi 3: Flutter Logs

```bash
# Jalankan app, lalu di terminal lain:
flutter logs
```

### Opsi 4: Real-time Monitoring

```bash
# Terminal 1: Run app
flutter run

# Terminal 2: Monitor logs
adb logcat -s flutter
```

## 🐛 Troubleshooting Spesifik

### Crash Saat Launch (Immediate)

**Kemungkinan**: MultiDex atau native library issue

**Solusi**:
```bash
# 1. Uninstall completely
adb uninstall com.example.habitual_mobile

# 2. Clean everything
flutter clean
cd android
gradlew clean
cd ..

# 3. Rebuild
flutter pub get
flutter run --release
```

### Crash Setelah Splash Screen

**Kemungkinan**: Database initialization error

**Solusi**:
```bash
# Clear app data
adb shell pm clear com.example.habitual_mobile

# Run again
flutter run
```

### Crash Saat Membuka Fitur Tertentu

**Kemungkinan**: Permission atau plugin issue

**Solusi**:
1. Cek log untuk error spesifik
2. Pastikan permission diberikan di Settings
3. Test di emulator untuk compare

### Crash Random

**Kemungkinan**: Memory issue

**Solusi**:
```kotlin
// Tambah di android/gradle.properties
org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m
```

## 📱 Testing Checklist

Setelah perbaikan, test scenario berikut:

### 1. Cold Start
- [ ] Uninstall app
- [ ] Install fresh
- [ ] Launch app
- [ ] App tidak crash

### 2. Basic Features
- [ ] Buka app
- [ ] Tambah habit
- [ ] Mark habit complete
- [ ] Buka Statistics
- [ ] Buka Settings
- [ ] Tidak ada crash

### 3. Stress Test
- [ ] Tambah 20+ habits
- [ ] Mark semua complete
- [ ] Rotate screen
- [ ] Background/foreground
- [ ] Tidak ada crash

### 4. Persistence
- [ ] Tambah data
- [ ] Close app (swipe dari recent)
- [ ] Open app lagi
- [ ] Data masih ada
- [ ] Tidak crash

## 🔧 Konfigurasi Device untuk Testing

### Minimum Requirements
- Android 5.0 (API 21) atau lebih tinggi
- RAM: 2GB minimum
- Storage: 100MB free space

### Developer Options Settings
```
Settings → Developer Options:
- USB Debugging: ON
- Stay Awake: ON (optional, untuk testing)
- Don't keep activities: OFF (untuk testing normal)
```

### App Permissions
```
Settings → Apps → Habitual:
- Storage: Allow (untuk database)
- Notifications: Allow (optional)
```

## 📊 Monitoring Performance

### Check Memory Usage

```bash
# Monitor memory saat app running
adb shell dumpsys meminfo com.example.habitual_mobile
```

### Check CPU Usage

```bash
# Monitor CPU
adb shell top | findstr habitual
```

### Check Battery Impact

```bash
# Battery stats
adb shell dumpsys batterystats com.example.habitual_mobile
```

## 🆘 Jika Masih Crash

### 1. Kumpulkan Informasi

```bash
# Device info
adb shell getprop ro.build.version.release  # Android version
adb shell getprop ro.product.model          # Device model
adb shell getprop ro.product.cpu.abi        # CPU architecture

# Save full log
adb logcat -d > full_crash_log.txt
```

### 2. Test di Emulator

```bash
# Jika work di emulator tapi crash di device:
# - Kemungkinan hardware/driver issue
# - Coba device lain
# - Update device firmware
```

### 3. Build Release APK

```bash
# Release build lebih stabil
flutter build apk --release

# Install manual
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 4. Simplify App

Temporary disable fitur untuk isolate masalah:

```dart
// Di main.dart, comment out:
// await notificationService.initialize();  // Disable notifications
// await databaseService.migrateDatabase(); // Skip migration
```

## 📝 Log Format untuk Report

Jika perlu bantuan, sertakan info berikut:

```
Device: [Model] (e.g., Samsung Galaxy S21)
Android Version: [Version] (e.g., Android 12)
Architecture: [ABI] (e.g., arm64-v8a)
RAM: [Size] (e.g., 8GB)

Crash Timing: [When] (e.g., immediately on launch, after 5 seconds)
Last Log Before Crash: [Log line]
Error Message: [If any]

Steps to Reproduce:
1. Install app
2. Launch app
3. [Crash occurs]
```

## ✅ Verifikasi Perbaikan

Aplikasi berhasil diperbaiki jika:
- ✅ App launch tanpa crash
- ✅ Semua fitur bisa diakses
- ✅ Data tersimpan dengan benar
- ✅ Tidak ada crash setelah 5 menit penggunaan
- ✅ Tidak ada crash saat rotate screen
- ✅ Tidak ada crash saat background/foreground

---

**Status**: 🔧 Perbaikan diterapkan, perlu testing di device
**File Baru**: 
- `HabitualApplication.kt` - Custom Application class
- `check_crash_log.bat` - Script untuk cek log
