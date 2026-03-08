# 🔥 Global Streak Fix - Troubleshooting

## 🐛 Masalah
Global streak (streak pengguna) tidak berfungsi atau tidak update.

## ✅ Perbaikan yang Diterapkan

### 1. **Logika Streak yang Diperbaiki**

**Masalah Sebelumnya:**
- Streak tidak mulai dari 1 saat pertama kali semua habit selesai
- Logika `daysDifference` tidak handle kasus pertama kali

**Solusi:**
```dart
// Jika streak saat ini 0, mulai dari 1
if (state.currentStreak == 0 && allHabitsCompleted) {
  // Mulai streak baru dari 1
}
```

### 2. **Enhanced Debug Logging**

Ditambahkan logging detail di:
- `user_streak_provider.dart` - Setiap step update streak
- `habit_provider.dart` - Pengecekan completion habits

### 3. **Refresh Streak di Home Page**

Ditambahkan refresh streak saat home page dibuka:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(userStreakProvider.notifier)._loadStreak();
  });
}
```

---

## 🔍 Cara Debug Global Streak

### Langkah 1: Lihat Log

Saat menjalankan aplikasi, perhatikan log berikut:

```
DEBUG _checkAndUpdateUserStreak: Starting check...
DEBUG _checkAndUpdateUserStreak: Total habits=X, Active habits=Y
DEBUG _checkAndUpdateUserStreak: Habit "Nama Habit" (key=Z) completed=true/false
DEBUG _checkAndUpdateUserStreak: Completed=X/Y, AllCompleted=true/false
DEBUG checkAndUpdateStreak: Called with allHabitsCompleted=true/false
DEBUG checkAndUpdateStreak: Current streak=X
DEBUG checkAndUpdateStreak: Today=..., LastCheck=...
```

### Langkah 2: Test Scenario

#### Scenario 1: Mulai Streak Baru
1. Pastikan tidak ada habit yang completed hari ini
2. Complete semua habit satu per satu
3. Setelah habit terakhir di-complete, cek log:
   ```
   DEBUG checkAndUpdateStreak: Starting new streak from 1
   ```
4. Lihat di header Home, streak harus menunjukkan 1

#### Scenario 2: Lanjutkan Streak
1. Besok, complete semua habit lagi
2. Cek log:
   ```
   DEBUG checkAndUpdateStreak: Consecutive day! NewStreak=2
   ```
3. Streak harus bertambah menjadi 2

#### Scenario 3: Reset Streak
1. Jangan complete salah satu habit hari ini
2. Besok, cek log:
   ```
   DEBUG checkAndUpdateStreak: Resetting streak from X to 0
   ```
3. Streak harus reset ke 0

---

## 🛠️ Cara Menjalankan Setelah Fix

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

### Langkah 3: Run dengan Log
```bash
flutter run --release
```

Atau untuk melihat log lebih detail:
```bash
flutter run
```

### Langkah 4: Monitor Log
```bash
# Di terminal terpisah
adb logcat | findstr "DEBUG checkAndUpdateStreak"
```

---

## 🎯 Testing Checklist

### Test 1: Streak Mulai dari 0
- [ ] Buka app baru (atau reset data)
- [ ] Tambah 2-3 habit
- [ ] Streak di header menunjukkan 0
- [ ] Complete semua habit
- [ ] Streak berubah menjadi 1

### Test 2: Streak Bertambah
- [ ] Hari berikutnya, complete semua habit lagi
- [ ] Streak bertambah menjadi 2
- [ ] Notifikasi milestone muncul (jika mencapai 3, 7, dll)

### Test 3: Streak Reset
- [ ] Jangan complete salah satu habit
- [ ] Besok, streak reset ke 0
- [ ] Notifikasi reset muncul

### Test 4: Multiple Habits
- [ ] Tambah 5+ habit
- [ ] Complete semua
- [ ] Streak update dengan benar

---

## 🐛 Troubleshooting

### Streak Tidak Update:

**Cek 1: Apakah semua habit completed?**
```
Lihat log:
DEBUG _checkAndUpdateUserStreak: Completed=X/Y
```
Pastikan X = Y (semua completed)

**Cek 2: Apakah sudah dicek hari ini?**
```
Lihat log:
DEBUG checkAndUpdateStreak: Already checked today, skipping
```
Jika muncul, tunggu hingga besok untuk melihat perubahan

**Cek 3: Apakah database tersimpan?**
```
Lihat log:
DEBUG checkAndUpdateStreak: Streak updated and saved
```
Jika tidak muncul, ada masalah di database

**Solusi:**
```bash
# Reset database
adb shell pm clear com.example.habitual_mobile
flutter run
```

### Streak Menunjukkan Angka Aneh:

**Solusi:**
```bash
# Uninstall dan install ulang
adb uninstall com.example.habitual_mobile
flutter run --release
```

### Log Tidak Muncul:

**Solusi:**
```bash
# Pastikan running di debug mode
flutter run

# Atau lihat log manual
adb logcat | findstr "DEBUG"
```

---

## 📊 Cara Kerja Global Streak

### Logika Update:

```
1. User complete/uncomplete habit
   ↓
2. toggleHabitCompletion() dipanggil
   ↓
3. _checkAndUpdateUserStreak() dipanggil
   ↓
4. Cek semua active habits completed?
   ↓
5. checkAndUpdateStreak(allCompleted) dipanggil
   ↓
6. Update streak berdasarkan logika:
   - Jika allCompleted && currentStreak=0 → streak=1
   - Jika allCompleted && daysDiff=1 → streak++
   - Jika allCompleted && daysDiff>1 → streak=1 (reset)
   - Jika !allCompleted && daysDiff>=1 → streak=0
   ↓
7. Save ke database
   ↓
8. Update UI (state change)
```

### Kondisi Streak:

| Kondisi | Streak Sebelum | Streak Sesudah | Keterangan |
|---------|----------------|----------------|------------|
| Pertama kali semua selesai | 0 | 1 | Mulai streak |
| Besok semua selesai lagi | 1 | 2 | Lanjut streak |
| Besok ada yang tidak selesai | 2 | 0 | Reset streak |
| Lewat 1 hari, lalu selesai | 2 | 1 | Mulai streak baru |

---

## 🎉 Verifikasi Berhasil

Streak berfungsi dengan benar jika:
- ✅ Streak mulai dari 1 saat pertama kali semua habit selesai
- ✅ Streak bertambah saat besok semua habit selesai lagi
- ✅ Streak reset ke 0 saat ada habit tidak selesai
- ✅ Notifikasi milestone muncul (3, 7, 14, 30 hari)
- ✅ Notifikasi reset muncul saat streak reset
- ✅ Streak ditampilkan di header Home dengan benar

---

**Status**: ✅ Global streak diperbaiki dengan logika yang lebih robust
**Versi**: 1.1.1
**Tanggal**: 24 Februari 2026
