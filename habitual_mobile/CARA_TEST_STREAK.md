# 🔥 Cara Test Global Streak

## 🎯 Quick Test Guide

### Persiapan:
```bash
cd "D:\Doc\File Aa\Aplikasi\Habitual Mobile\Kiro\habitual_mobile"
flutter clean
flutter pub get
adb uninstall com.example.habitual_mobile
flutter run
```

---

## 📝 Test Scenario 1: Mulai Streak Baru

### Langkah:
1. **Buka app** (fresh install atau data kosong)
2. **Lihat header Home** → Streak harus menunjukkan **0** 🔥
3. **Tambah 2 habit**:
   - "Olahraga Pagi"
   - "Minum Air 8 Gelas"
4. **Complete habit pertama** (centang checkbox)
   - Lihat log: `DEBUG _checkAndUpdateUserStreak: Completed=1/2`
   - Streak masih **0** (belum semua selesai)
5. **Complete habit kedua** (centang checkbox)
   - Lihat log: `DEBUG _checkAndUpdateUserStreak: Completed=2/2, AllCompleted=true`
   - Lihat log: `DEBUG checkAndUpdateStreak: Starting new streak from 1`
   - **Streak berubah menjadi 1** 🎉

### Expected Result:
- ✅ Streak di header: **1 hari**
- ✅ Ikon api muncul
- ✅ Log menunjukkan "Starting new streak from 1"

---

## 📝 Test Scenario 2: Lanjutkan Streak

### Langkah:
1. **Besok** (atau ubah tanggal sistem untuk test)
2. **Buka app**
3. **Lihat header** → Streak masih **1**
4. **Uncomplete semua habit** (uncheck)
5. **Complete semua habit lagi**
   - Lihat log: `DEBUG checkAndUpdateStreak: Consecutive day! NewStreak=2`
   - **Streak berubah menjadi 2** 🎉

### Expected Result:
- ✅ Streak di header: **2 hari**
- ✅ Log menunjukkan "Consecutive day! NewStreak=2"

---

## 📝 Test Scenario 3: Notifikasi Milestone

### Langkah:
1. **Lanjutkan streak hingga 3 hari**
2. Saat mencapai **3 hari**:
   - Notifikasi muncul: "Hebat! Anda telah mencapai streak 3 hari! 🎉"

### Milestone Lainnya:
- **7 hari**: "Luar biasa! Streak 7 hari tercapai! Satu minggu penuh! 🌟"
- **14 hari**: "Fantastis! Streak 14 hari! Dua minggu konsisten! 💪"
- **30 hari**: "Menakjubkan! Streak 30 hari! Satu bulan penuh! 🏆"

---

## 📝 Test Scenario 4: Reset Streak

### Langkah:
1. **Hari ini**, jangan complete salah satu habit
2. **Besok**, buka app
3. **Lihat log**: `DEBUG checkAndUpdateStreak: Resetting streak from X to 0`
4. **Streak reset ke 0**
5. **Notifikasi muncul**: "💔 Streak Reset - Streak Anda telah direset..."

### Expected Result:
- ✅ Streak di header: **0 hari**
- ✅ Notifikasi reset muncul
- ✅ Log menunjukkan "Resetting streak"

---

## 📝 Test Scenario 5: Streak dengan Banyak Habit

### Langkah:
1. **Tambah 5 habit**
2. **Complete 4 habit** (1 tidak di-complete)
   - Lihat log: `DEBUG _checkAndUpdateUserStreak: Completed=4/5, AllCompleted=false`
   - **Streak tidak berubah** (belum semua selesai)
3. **Complete habit terakhir**
   - Lihat log: `DEBUG _checkAndUpdateUserStreak: Completed=5/5, AllCompleted=true`
   - **Streak update**

### Expected Result:
- ✅ Streak hanya update saat SEMUA habit selesai
- ✅ Log menunjukkan jumlah completed dengan benar

---

## 🔍 Cara Lihat Log

### Opsi 1: Flutter Run (Recommended)
```bash
flutter run
# Log akan muncul di terminal
```

### Opsi 2: ADB Logcat
```bash
# Terminal 1: Run app
flutter run --release

# Terminal 2: Monitor log
adb logcat | findstr "DEBUG checkAndUpdateStreak"
```

### Opsi 3: Filter Specific
```bash
# Hanya log streak
adb logcat | findstr "checkAndUpdateStreak"

# Hanya log habit completion
adb logcat | findstr "_checkAndUpdateUserStreak"
```

---

## 🐛 Jika Streak Tidak Update

### Debug Steps:

#### 1. Cek Log Completion
```
Cari log:
DEBUG _checkAndUpdateUserStreak: Completed=X/Y, AllCompleted=...
```
- Jika X ≠ Y → Belum semua habit selesai
- Jika AllCompleted=false → Normal, streak tidak update

#### 2. Cek Log Streak Update
```
Cari log:
DEBUG checkAndUpdateStreak: Called with allHabitsCompleted=true
```
- Jika tidak muncul → `_checkAndUpdateUserStreak` tidak dipanggil
- Jika muncul tapi streak tidak update → Cek logika di bawahnya

#### 3. Cek Already Checked Today
```
Cari log:
DEBUG checkAndUpdateStreak: Already checked today, skipping
```
- Jika muncul → Normal, tunggu hingga besok
- Streak hanya update sekali per hari

#### 4. Reset Data
```bash
# Jika masih bermasalah, reset data
adb shell pm clear com.example.habitual_mobile
flutter run
```

---

## ✅ Checklist Verifikasi

Setelah test, pastikan:

### Functionality:
- [ ] Streak mulai dari 1 saat pertama kali semua habit selesai
- [ ] Streak bertambah saat besok semua habit selesai lagi
- [ ] Streak reset ke 0 saat ada habit tidak selesai
- [ ] Streak ditampilkan di header dengan benar
- [ ] Ikon api muncul di header

### Notifications:
- [ ] Notifikasi milestone muncul (3, 7, 14, 30 hari)
- [ ] Notifikasi reset muncul saat streak reset

### Logging:
- [ ] Log completion muncul saat toggle habit
- [ ] Log streak update muncul dengan detail
- [ ] Log menunjukkan jumlah completed yang benar

---

## 🎉 Success Criteria

Global streak berfungsi dengan benar jika:
1. ✅ Streak mulai dari 1 (bukan 0 atau angka aneh)
2. ✅ Streak bertambah setiap hari jika semua habit selesai
3. ✅ Streak reset jika ada habit tidak selesai
4. ✅ Notifikasi milestone dan reset muncul
5. ✅ UI update dengan benar (tidak perlu restart app)

---

**Happy Testing! 🚀**
