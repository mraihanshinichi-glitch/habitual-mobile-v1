# Setup Guide - Habitual Mobile

## 📋 Prerequisites

Pastikan Anda sudah menginstall:
- Flutter SDK ≥ 3.8.1
- Dart SDK ≥ 3.8.0
- Android Studio dengan Android SDK
- Emulator Android atau device fisik

## 🚀 Langkah Setup

### 1. Clone & Install Dependencies
```bash
cd habitual_mobile
flutter pub get
```

### 2. Generate Kode Database
```bash
dart run build_runner build
```

### 3. Jalankan Aplikasi
```bash
flutter run
```

## 📱 Testing di Device

### Android Emulator
1. Buka Android Studio
2. Buka AVD Manager
3. Create atau start emulator
4. Jalankan `flutter run`

### Physical Device
1. Enable Developer Options di Android
2. Enable USB Debugging
3. Connect device via USB
4. Jalankan `flutter run`

## 🔧 Troubleshooting

### Error: Build Runner
Jika ada error saat generate kode:
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build
```

### Error: Dependencies
Jika ada conflict dependencies:
```bash
flutter pub deps
flutter pub upgrade
```

### Error: Android License
Jika ada masalah Android license:
```bash
flutter doctor --android-licenses
```

## 📊 Struktur Database

Aplikasi akan otomatis membuat database Isar dengan:
- 5 kategori default (Kesehatan, Belajar, Kerja, Olahraga, Hobi)
- Schema untuk Category, Habit, dan HabitLog
- Data tersimpan lokal di device

## 🎯 Fitur yang Bisa Ditest

1. **Tambah Kategori**: Settings → Kelola Kategori → +
2. **Tambah Kebiasaan**: Home → + → Pilih kategori
3. **Mark Complete**: Centang checkbox di habit card
4. **Lihat Streak**: Ikon api dengan angka di habit card
5. **Statistik**: Tab Statistik untuk melihat chart
6. **Arsip**: Edit habit → Arsipkan
7. **Lihat Arsip**: Settings → Kebiasaan Terarsip

## 📝 Notes

- Database menggunakan Isar (NoSQL) untuk performa tinggi
- State management dengan Riverpod
- UI menggunakan Material 3 Design
- Support Indonesian locale untuk tanggal
- Semua data tersimpan lokal (offline-first)

## 🐛 Known Issues

- Warning tentang `withOpacity` deprecated (tidak mempengaruhi fungsi)
- Beberapa dependencies versi lama (masih kompatibel)

Aplikasi siap digunakan! 🎉