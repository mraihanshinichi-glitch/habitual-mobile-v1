# 🔧 Build Error Fix

## 🐛 Error yang Terjadi

```
lib/features/home/home_page.dart:25:45: Error: The method '_loadStreak' isn't defined for the type 'UserStreakNotifier'.
```

## 📋 Penyebab

Method `_loadStreak()` di `UserStreakNotifier` adalah private (diawali dengan underscore `_`), sehingga tidak bisa dipanggil dari luar class.

## ✅ Solusi

### Tambah Method Public

Di `lib/shared/providers/user_streak_provider.dart`:

```dart
// Method private (tidak bisa dipanggil dari luar)
Future<void> _loadStreak() async {
  final streak = await _repository.getUserStreak();
  state = streak;
}

// Method public (bisa dipanggil dari luar)
Future<void> reloadStreak() async {
  await _loadStreak();
}
```

### Update Home Page

Di `lib/features/home/home_page.dart`:

```dart
// Sebelum (ERROR):
ref.read(userStreakProvider.notifier)._loadStreak();

// Sesudah (FIXED):
ref.read(userStreakProvider.notifier).reloadStreak();
```

---

## 🚀 Cara Menjalankan Setelah Fix

```bash
cd "D:\Doc\File Aa\Aplikasi\Habitual Mobile\Kiro\habitual_mobile"
flutter clean
flutter pub get
adb uninstall com.example.habitual_mobile
flutter run --release
```

---

## ✅ Verifikasi

Build berhasil jika tidak ada error dan aplikasi bisa dijalankan:

```bash
flutter run
# Tidak ada error "The method '_loadStreak' isn't defined"
```

---

**Status**: ✅ Fixed
**Versi**: 1.1.2
