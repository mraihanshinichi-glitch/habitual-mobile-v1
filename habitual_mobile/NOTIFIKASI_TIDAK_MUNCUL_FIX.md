# 🔔 Fix: Notifikasi Tidak Muncul Meskipun App Terbuka

## 🐛 Masalah

Notifikasi pengingat harian tidak muncul meskipun:
- App tetap terbuka
- Sudah menunggu sampai besok
- Permission sudah diberikan

## 📋 Penyebab

### 1. **Scheduled Notification Limitations**
- `flutter_local_notifications` dengan `zonedSchedule` memerlukan app dalam keadaan tertentu
- Notifikasi mungkin tidak muncul jika app terus terbuka (foreground)
- Android Doze mode bisa menunda notifikasi

### 2. **Battery Optimization**
- Android membatasi background task untuk hemat baterai
- Notifikasi bisa di-delay atau di-skip

### 3. **App Foreground**
- Beberapa device tidak menampilkan notifikasi jika app sedang aktif di foreground

---

## ✅ Solusi yang Diterapkan

### 1. **Test Notification Saat App Dibuka**

Setiap kali app dibuka, akan muncul test notification untuk verify bahwa notifikasi bekerja:

```dart
// Di background_service.dart
await _showDailyCheckNotification();
```

**Benefit:**
- User tahu notifikasi berfungsi
- Confirm permission diberikan
- Debug tool untuk developer

### 2. **Update Background Service**

Logika check streak diupdate untuk match logika baru (minimal 1 habit completed):

```dart
// Check if any habit was completed yesterday (bukan all)
bool anyCompletedYesterday = false;
```

### 3. **Enhanced Logging**

Tambah logging untuk track notifikasi:
```
DEBUG NotificationService: Scheduled daily reminder for "Habit" at HH:MM
DEBUG BackgroundService: Daily check notification shown
```

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

### Langkah 4: Verify Test Notification
Saat app dibuka, harus muncul notifikasi:
```
"Habitual Mobile - App dibuka pada HH:MM. Notifikasi berfungsi dengan baik! ✅"
```

---

## 🔍 Testing Notifikasi

### Test 1: Test Notification (Immediate)

**Cara:**
1. Buka app
2. **Notifikasi test harus muncul** ✅

**Jika Tidak Muncul:**
- Permission belum diberikan
- Notifikasi di-block di system settings
- Battery optimization terlalu agresif

### Test 2: Scheduled Notification (2 Menit)

**Cara:**
1. Tambah habit dengan pengingat
2. Set waktu 2 menit dari sekarang
3. Save
4. **Minimize app** (jangan close)
5. Tunggu 2 menit
6. **Notifikasi harus muncul** ✅

**Jika Tidak Muncul:**
- Lihat log: `adb logcat | findstr "NotificationService"`
- Cek pending notifications
- Coba restart app

### Test 3: Daily Notification (Besok)

**Cara:**
1. Set pengingat untuk besok pagi (misal: 08:00)
2. Close app
3. **Besok pagi, buka app sebelum jam 08:00**
4. Background service akan reschedule
5. Jam 08:00, notifikasi harus muncul ✅

**Catatan:**
- **App harus dibuka minimal sekali sehari** untuk reschedule
- Jika tidak buka app, notifikasi tidak akan muncul

---

## ⚙️ Konfigurasi untuk Notifikasi Reliable

### 1. Disable Battery Optimization

```
Settings → Apps → Habitual → Battery → Unrestricted
```

**Atau:**
```
Settings → Battery → Battery optimization → Habitual → Don't optimize
```

### 2. Allow All Permissions

```
Settings → Apps → Habitual → Permissions:
- Notifications: Allow
- Alarms & reminders: Allow
```

### 3. Disable Do Not Disturb (Saat Testing)

```
Settings → Sound → Do Not Disturb → OFF
```

**Atau tambah exception:**
```
Settings → Sound → Do Not Disturb → Apps → Habitual → Allow
```

### 4. Keep App in Recent Apps

- Jangan swipe app dari recent apps
- Biarkan app running di background
- Buka app minimal sekali sehari

---

## 🐛 Troubleshooting

### Notifikasi Test Tidak Muncul

**Cek 1: Permission**
```bash
adb shell dumpsys notification_listener
```

**Cek 2: Log**
```bash
adb logcat | findstr "NotificationService"
```

Cari:
```
DEBUG NotificationService: Test notification sent at HH:MM
```

**Cek 3: System Settings**
```
Settings → Apps → Habitual → Notifications → ON
```

**Solusi:**
```bash
# Reinstall app
adb uninstall com.example.habitual_mobile
flutter run --release

# Izinkan permission saat popup muncul
```

### Notifikasi Scheduled Tidak Muncul

**Cek 1: Pending Notifications**
```bash
adb logcat | findstr "Scheduled daily reminder"
```

**Cek 2: Exact Alarm Permission**
```
Settings → Apps → Habitual → Alarms & reminders → Allow
```

**Cek 3: Battery Optimization**
```
Settings → Apps → Habitual → Battery → Unrestricted
```

**Solusi:**
```bash
# Buka app untuk reschedule
flutter run

# Atau force reschedule
adb shell am force-stop com.example.habitual_mobile
flutter run
```

### Notifikasi Delay atau Tidak Tepat Waktu

**Penyebab:**
- Battery optimization aktif
- Doze mode
- App tidak di-whitelist

**Solusi:**
1. Disable battery optimization
2. Keep app in recent apps
3. Buka app setiap hari

---

## 📊 Cara Kerja Notifikasi

### Flow Notifikasi:

```
1. User set pengingat saat buat habit
   ↓
2. scheduleDailyHabitReminder() dipanggil
   ↓
3. Notifikasi dijadwalkan dengan zonedSchedule
   ↓
4. Notifikasi muncul pada waktu yang ditentukan
   ↓
5. Repeat setiap hari (matchDateTimeComponents.time)
```

### Limitations:

1. **App Harus Dibuka Minimal Sekali Sehari**
   - Untuk reschedule notifikasi
   - Untuk check streak
   - Untuk update data

2. **Notifikasi Bisa Delay**
   - Jika battery optimization aktif
   - Jika device dalam doze mode
   - Jika app di-force stop

3. **Notifikasi Mungkin Tidak Muncul Jika:**
   - App terus di foreground (beberapa device)
   - Permission tidak diberikan
   - Do Not Disturb aktif

---

## 💡 Rekomendasi

### Untuk User:

1. **Buka app setiap hari** - Minimal sekali untuk reschedule
2. **Disable battery optimization** - Untuk notifikasi yang reliable
3. **Allow all permissions** - Notification, Exact Alarm
4. **Jangan force stop app** - Biarkan running di background

### Untuk Developer:

1. **Test di real device** - Emulator tidak reliable untuk notifikasi
2. **Test dengan battery optimization** - Simulate real-world
3. **Monitor log** - Untuk debug issues
4. **Consider WorkManager** - Untuk true background task (lebih kompleks)

---

## ✅ Verifikasi

Notifikasi berfungsi dengan benar jika:
- ✅ Test notification muncul saat buka app
- ✅ Scheduled notification muncul pada waktu yang ditentukan
- ✅ Notifikasi tetap muncul setelah app di-minimize
- ✅ Notifikasi di-reschedule setelah app dibuka lagi

---

## 🎯 Alternative Solution (Future)

Untuk notifikasi yang benar-benar reliable tanpa perlu buka app:

### 1. WorkManager
```yaml
dependencies:
  workmanager: ^0.5.0
```

**Benefit:**
- True background task
- Tidak perlu buka app
- Lebih reliable

**Drawback:**
- Lebih kompleks
- Perlu native code
- Battery usage lebih tinggi

### 2. AlarmManager (Native)
```kotlin
// Native Android code
AlarmManager.setExactAndAllowWhileIdle()
```

**Benefit:**
- Paling reliable
- Exact timing
- Work even in doze mode

**Drawback:**
- Perlu native code
- Platform specific
- Kompleks untuk maintain

---

**Status**: ✅ Test notification ditambahkan
**Versi**: 1.2.1
**Tanggal**: 24 Februari 2026

**Catatan**: Untuk notifikasi yang benar-benar background, perlu implementasi WorkManager atau AlarmManager native, yang lebih kompleks dan di luar scope update ini.
