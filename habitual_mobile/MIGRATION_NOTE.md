# Migration Note - Isar to Hive

## Status Saat Ini

Aplikasi sedang dalam proses migrasi dari **Isar Database** ke **Hive Database** karena masalah kompatibilitas dengan platform web.

### Masalah yang Ditemukan

1. **Isar + Web = Error**: Isar menggunakan integer 64-bit yang tidak bisa direpresentasikan dengan tepat di JavaScript
2. **Visual Studio Required**: Windows desktop development memerlukan Visual Studio yang belum terinstall

### Solusi yang Direkomendasikan

#### Opsi 1: Gunakan Android Emulator (RECOMMENDED)
```bash
# 1. Buka Android Studio
# 2. Buka AVD Manager (Tools → Device Manager)
# 3. Create atau start Android emulator
# 4. Jalankan aplikasi
flutter run
```

#### Opsi 2: Gunakan Physical Android Device
```bash
# 1. Enable Developer Options di Android
# 2. Enable USB Debugging
# 3. Connect device via USB
# 4. Jalankan aplikasi
flutter run
```

#### Opsi 3: Install Visual Studio untuk Windows Desktop
```bash
# 1. Download Visual Studio Community
# 2. Install dengan workload "Desktop development with C++"
# 3. Restart terminal
# 4. Jalankan aplikasi
flutter run -d windows
```

## Struktur Aplikasi yang Sudah Selesai

### ✅ Completed Features:
- [x] Model data (Category, Habit, HabitLog)
- [x] Repository pattern
- [x] State management dengan Riverpod
- [x] UI Components (HabitCard, CategorySelector)
- [x] Home Page dengan daftar kebiasaan
- [x] Add/Edit Habit Page
- [x] Stats Page dengan charts
- [x] Settings Page
- [x] Categories Management
- [x] Archived Habits
- [x] Material 3 Design
- [x] Bottom Navigation

### 🔄 In Progress:
- [ ] Migrasi lengkap ke Hive (70% selesai)
- [ ] Testing di Android emulator
- [ ] Bug fixes untuk Hive implementation

### 📝 Known Issues:
1. Aplikasi tidak bisa run di web karena Isar integer limitation
2. Perlu Android emulator atau physical device untuk testing
3. Beberapa file masih menggunakan Isar API yang perlu diupdate

## Cara Melanjutkan Development

### Jika Ingin Tetap Menggunakan Isar (Android Only):
```bash
# Revert ke Isar
git checkout <commit-before-hive-migration>

# Atau manual:
# 1. Update pubspec.yaml kembali ke Isar
# 2. Restore file-file model, repository, dan database service
# 3. Run build_runner
dart run build_runner build --delete-conflicting-outputs

# 4. Run di Android
flutter run
```

### Jika Ingin Melanjutkan Migrasi Hive:
File-file yang masih perlu diupdate:
1. `lib/shared/providers/habit_provider.dart` - Update untuk HabitWithCategory
2. `lib/shared/widgets/habit_card.dart` - Update untuk menggunakan key instead of id
3. `lib/features/home/home_page.dart` - Update habit operations
4. `lib/features/home/add_habit_page.dart` - Update CRUD operations
5. `lib/features/settings/categories_page.dart` - Update category operations
6. `lib/features/settings/add_category_page.dart` - Update category CRUD

## Rekomendasi

**Untuk development dan testing yang cepat**, gunakan **Android Emulator** dengan **Isar Database** (versi original).

**Untuk production dan multi-platform**, lanjutkan migrasi ke **Hive** atau gunakan alternatif lain seperti:
- **Drift** (formerly Moor) - SQL database dengan web support
- **ObjectBox** - NoSQL dengan performa tinggi
- **Sembast** - NoSQL pure Dart

## Contact & Support

Jika ada pertanyaan atau butuh bantuan melanjutkan development, silakan hubungi developer atau buat issue di repository.

---
**Last Updated**: December 18, 2025