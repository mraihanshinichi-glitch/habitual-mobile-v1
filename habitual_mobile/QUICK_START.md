# Quick Start Guide - Habitual Mobile

## 🚀 Cara Tercepat Menjalankan Aplikasi

### Prerequisites
- Flutter SDK ≥ 3.8.1
- Android Studio dengan Android SDK
- Android Emulator atau Physical Device

### Step-by-Step

#### 1. Setup Android Emulator
```bash
# Buka Android Studio
# Tools → Device Manager → Create Device
# Pilih device (misal: Pixel 7)
# Download system image (API 34 recommended)
# Start emulator
```

#### 2. Clone & Setup Project
```bash
cd habitual_mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

#### 3. Run Application
```bash
# Pastikan emulator sudah running
flutter devices

# Run aplikasi
flutter run
```

## 🎯 Fitur yang Bisa Ditest

### 1. Home Page
- ✅ Lihat daftar kebiasaan hari ini
- ✅ Tambah kebiasaan baru (tombol +)
- ✅ Mark kebiasaan sebagai selesai (checkbox)
- ✅ Lihat streak (ikon api dengan angka)

### 2. Add/Edit Habit
- ✅ Form tambah kebiasaan
- ✅ Pilih kategori dari dropdown
- ✅ Edit kebiasaan yang sudah ada
- ✅ Arsipkan kebiasaan

### 3. Statistics Page
- ✅ Pie chart distribusi per kategori
- ✅ Summary cards (Total, Minggu Ini, Bulan Ini)
- ✅ Detail list kategori dengan jumlah

### 4. Settings Page
- ✅ Kelola kategori (tambah, edit, hapus)
- ✅ Lihat kebiasaan terarsip
- ✅ About aplikasi

### 5. Category Management
- ✅ Tambah kategori baru
- ✅ Pilih ikon dan warna
- ✅ Preview kategori
- ✅ Edit/hapus kategori

## 📱 Testing Scenarios

### Scenario 1: First Time User
1. Buka aplikasi → Lihat empty state
2. Tap tombol + → Tambah kebiasaan pertama
3. Pilih kategori "Kesehatan" → Isi "Minum air 8 gelas"
4. Save → Kembali ke home, lihat kebiasaan baru
5. Tap checkbox → Mark sebagai selesai
6. Lihat perubahan visual (strikethrough, streak)

### Scenario 2: Power User
1. Tambah 5+ kebiasaan dengan kategori berbeda
2. Mark beberapa sebagai selesai
3. Buka Stats → Lihat pie chart dan statistik
4. Arsipkan 1 kebiasaan
5. Buka Settings → Kelola Kategori → Tambah kategori baru
6. Buat kebiasaan dengan kategori baru

### Scenario 3: Data Management
1. Tambah kategori "Fitness" dengan ikon dan warna
2. Buat kebiasaan "Push up 20x" dengan kategori Fitness
3. Edit kebiasaan → Ubah deskripsi
4. Arsipkan kebiasaan lama
5. Lihat Archived Habits → Restore kebiasaan

## 🐛 Troubleshooting

### Error: No devices found
```bash
# Check emulator
flutter emulators
flutter emulators --launch <emulator_id>

# Check connected devices
flutter devices
adb devices
```

### Error: Build failed
```bash
# Clean dan rebuild
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Error: Gradle issues
```bash
# Di folder android/
./gradlew clean

# Atau
cd android
./gradlew clean
cd ..
flutter run
```

## 📊 Expected Results

Setelah testing, Anda harus bisa:
- ✅ Membuat dan mengelola kebiasaan
- ✅ Melihat streak yang bertambah
- ✅ Melihat statistik dalam bentuk chart
- ✅ Mengelola kategori dengan ikon dan warna
- ✅ Mengarsipkan dan restore kebiasaan
- ✅ Navigasi lancar antar halaman

## 🎉 Success Criteria

Aplikasi berhasil jika:
1. **Functional**: Semua CRUD operations bekerja
2. **Visual**: UI responsive dan menarik
3. **Data**: Database menyimpan data dengan benar
4. **Performance**: Aplikasi lancar tanpa lag
5. **UX**: Flow penggunaan intuitif

---
**Happy Testing! 🚀**