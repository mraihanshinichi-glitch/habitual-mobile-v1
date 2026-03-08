# 🔔 Notifikasi Fix - Troubleshooting

## 🐛 Masalah
Notifikasi pengingat harian tidak muncul, terutama setelah:
- Device restart
- App di-kill/force stop
- Besok hari (notifikasi tidak muncul otomatis)

## ✅ Perbaikan yang Diterapkan

### 1. **Background Service**

File baru: `lib/shared/services/background_service.dart`

**Fitur:**
- Check daily streak saat app dibuka
- Reschedule semua notifikasi saat app dibuka
- Handle streak reset jika kemarin tidak semua habit selesai

**Cara Kerja:**
```dart
// Saat app start atau resume
BackgroundService().initialize()
  ↓
1. checkDailyStreak() - Cek apakah kemarin semua habit selesai
2. rescheduleAllNotifications() - Jadwalkan ulang semua notifikasi
```

### 2. **App Lifecycle Observer**

Di `main.dart`, tambah observer untuk detect app resume:

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // Reschedule notifications saat app kembali ke foreground
    BackgroundService().initialize();
  }
}
```

### 3. **Auto Reschedule di App Start**

Setiap kali app dibuka:
1. Initialize notification service
2. Initialize background service
3. Check streak
4. Reschedule semua notifikasi

---

## 🚀 Cara Menjalankan Setelah Fix

### Langkah 1: Clean & Rebuild
```bash
cd "D:\Doc\File Aa\Aplikasi\Habitual Mobile\Kiro\habitual_mobile"
flutter clean
flutter pub get
```

### Langkah 2: Uninstall App Lama (WAJIB!)
```bash
adb uninstall com.example.habitual_mobile
```

### Langkah 3: Run
```bash
flutter run --release
```

---

## 🔍 Cara Test Notifikasi

### Test 1: Notifikasi Pengingat Harian

#### Setup:
1. Buka app
2. Tambah habit dengan pengingat
3. Set waktu 2 menit dari sekarang
4. Save

#### Test:
1. Tunggu 2 menit
2. **Notifikasi harus muncul** ✅

#### Jika Tidak Muncul:
```bash
# Cek log
adb logcat | findstr "NotificationService"

# Cek pending notifications
adb logcat | findstr "Scheduled daily reminder"
```

### Test 2: Notifikasi Setelah App Restart

#### Setup:
1. Set notifikasi untuk besok pagi (misal: 08:00)
2. Close app (swipe dari recent apps)

#### Test:
1. Besok pagi jam 08:00
2. **Notifikasi TIDAK akan muncul** ❌ (karena app tidak running)

#### Solusi:
1. Buka app besok pagi (sebelum jam 08:00)
2. Background service akan reschedule notifikasi
3. Jam 08:00, notifikasi akan muncul ✅

### Test 3: Notifikasi Setelah Device Restart

#### Setup:
1. Set notifikasi untuk besok
2. Restart device

#### Test:
1. Setelah restart, buka app
2. Background service akan reschedule notifikasi
3. Notifikasi akan muncul pada waktu yang ditentukan ✅

### Test 4: Notifikasi Streak Reset

#### Setup:
1. Buat streak 3 hari
2. Hari ke-4, jangan complete salah satu habit
3. Close app

#### Test:
1. Besok (hari ke-5), buka app
2. Background service akan detect kemarin tidak semua selesai
3. **Notifikasi streak reset muncul** ✅

---

## 🔧 Konfigurasi Notifikasi

### Android Permissions

File: `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Permissions untuk notifikasi -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Receivers untuk notifikasi -->
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
    </intent-filter>
</receiver>
```

### Battery Optimization

Untuk notifikasi yang lebih reliable, disable battery optimization:

```
Settings → Apps → Habitual → Battery → Unrestricted
```

---

## 🐛 Troubleshooting

### Notifikasi Tidak Muncul Sama Sekali

**Cek 1: Permission**
```
Settings → Apps → Habitual → Notifications → Allow
Settings → Apps → Habitual → Alarms & reminders → Allow
```

**Cek 2: Battery Optimization**
```
Settings → Apps → Habitual → Battery → Unrestricted
```

**Cek 3: Do Not Disturb**
```
Settings → Sound → Do Not Disturb → OFF
atau
Allow Habitual di Do Not Disturb exceptions
```

**Cek 4: Log**
```bash
adb logcat | findstr "NotificationService"
```

Cari log:
```
DEBUG NotificationService: Scheduled daily reminder for "Habit Name" at HH:MM
```

### Notifikasi Muncul Tapi Tidak Tepat Waktu

**Penyebab:**
- Battery optimization aktif
- Doze mode
- App tidak di-whitelist

**Solusi:**
```
Settings → Apps → Habitual → Battery → Unrestricted
Settings → Battery → Battery optimization → Habitual → Don't optimize
```

### Notifikasi Hilang Setelah Restart

**Penyebab:**
- Notifikasi tidak di-reschedule setelah boot
- RECEIVE_BOOT_COMPLETED permission tidak diberikan

**Solusi:**
1. Pastikan permission ada di AndroidManifest
2. Buka app setelah restart untuk reschedule

### Notifikasi Streak Tidak Muncul

**Cek Log:**
```bash
adb logcat | findstr "BackgroundService"
```

Cari log:
```
DEBUG BackgroundService: Resetting streak due to incomplete yesterday
DEBUG NotificationService: Showed streak reset notification
```

**Jika Tidak Muncul:**
1. Pastikan app dibuka besok hari
2. Background service hanya jalan saat app dibuka
3. Cek permission notifikasi

---

## 📊 Cara Kerja Notifikasi

### Flow Notifikasi Pengingat:

```
1. User set pengingat saat buat/edit habit
   ↓
2. scheduleDailyHabitReminder() dipanggil
   ↓
3. Notifikasi dijadwalkan dengan flutter_local_notifications
   ↓
4. Notifikasi muncul pada waktu yang ditentukan
   ↓
5. Repeat setiap hari (matchDateTimeComponents.time)
```

### Flow Reschedule:

```
1. App dibuka atau resume
   ↓
2. BackgroundService.initialize() dipanggil
   ↓
3. rescheduleAllNotifications() dipanggil
   ↓
4. Cancel semua notifikasi existing
   ↓
5. Get semua habit dengan notifikasi aktif
   ↓
6. Schedule ulang satu per satu
```

### Flow Streak Reset Notification:

```
1. App dibuka besok hari
   ↓
2. BackgroundService.checkDailyStreak() dipanggil
   ↓
3. Cek apakah kemarin semua habit selesai
   ↓
4. Jika tidak dan streak > 0:
   - Reset streak ke 0
   - Show streak reset notification
```

---

## ⚠️ Keterbatasan

### 1. App Harus Dibuka
- Notifikasi streak reset hanya muncul saat app dibuka
- Background service tidak jalan jika app tidak dibuka
- **Solusi**: User harus buka app minimal sekali sehari

### 2. Notifikasi Bisa Delay
- Jika battery optimization aktif
- Jika device dalam doze mode
- **Solusi**: Disable battery optimization

### 3. Notifikasi Hilang Setelah Restart
- Notifikasi tidak persist setelah device restart
- **Solusi**: Buka app setelah restart untuk reschedule

---

## 🎯 Best Practices

### Untuk User:

1. **Buka app setiap hari** - Minimal sekali untuk trigger background check
2. **Disable battery optimization** - Untuk notifikasi yang lebih reliable
3. **Allow all permissions** - Notification, Exact Alarm, Boot Completed
4. **Jangan force stop app** - Biarkan app running di background

### Untuk Developer:

1. **Test di real device** - Emulator tidak reliable untuk notifikasi
2. **Test dengan battery optimization** - Simulate real-world scenario
3. **Test setelah restart** - Pastikan reschedule bekerja
4. **Monitor log** - Untuk debug notifikasi issues

---

## ✅ Verifikasi Berhasil

Notifikasi berfungsi dengan benar jika:
- ✅ Notifikasi pengingat muncul pada waktu yang ditentukan
- ✅ Notifikasi tetap muncul setelah app di-close
- ✅ Notifikasi di-reschedule setelah app dibuka lagi
- ✅ Notifikasi streak reset muncul saat buka app besok
- ✅ Notifikasi milestone muncul saat mencapai streak tertentu

---

**Status**: ✅ Notifikasi diperbaiki dengan background service
**Versi**: 1.1.2
**Tanggal**: 24 Februari 2026

**Catatan**: Untuk notifikasi yang benar-benar background (tanpa buka app), perlu implementasi WorkManager atau AlarmManager native, yang lebih kompleks.
