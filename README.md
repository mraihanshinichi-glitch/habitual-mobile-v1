# Habitual Mobile

Aplikasi pelacak kebiasaan (habit tracker) yang dibuat dengan Flutter untuk membantu Anda membangun rutinitas positif dan mencapai tujuan harian.

## 🚀 Fitur Utama

### ✅ Manajemen Kebiasaan (CRUD)
- Tambah, edit, dan hapus kebiasaan
- Deskripsi detail untuk setiap kebiasaan
- Kategorisasi kebiasaan dengan warna dan ikon

### 🔍 Pencarian Kebiasaan
- Search bar di Home untuk mencari kebiasaan
- Pencarian real-time berdasarkan judul, deskripsi, dan kategori
- Tampilan hasil yang responsif

### 🔥 Sistem Streak
- Hitung streak berturut-turut per kebiasaan
- Visual feedback dengan ikon api
- Reset otomatis jika terlewat satu hari

### 🔥 Streak Pengguna (Global)
- Streak bertambah saat semua kebiasaan selesai dalam satu hari
- Streak berkurang saat ada kebiasaan yang tidak selesai
- Notifikasi milestone (3, 7, 14, 30, 50, 100 hari)
- Notifikasi saat streak reset

### 📁 Kategori Kustom
- Buat kategori sesuai kebutuhan
- Pilih dari berbagai ikon dan warna
- Kategori default: Kesehatan, Belajar, Kerja, Olahraga, Hobi

### 📊 Statistik & Grafik
- Pie chart distribusi penyelesaian per kategori
- Statistik mingguan dan bulanan
- Total penyelesaian kebiasaan

### 🗄️ Arsip Kebiasaan
- Arsipkan kebiasaan tanpa menghapus data
- Aktifkan kembali kebiasaan yang diarsipkan
- Soft delete untuk menjaga riwayat

### 📅 Frekuensi Kebiasaan
- Sekali
- Harian
- Mingguan

### ⌛ Timer Kebiasaan
- Timer khusus untuk setiap kebiasaan
- Catat durasi pengerjaan
- Tampilkan waktu rata-rata per kebiasaan

### 🔔 Notifikasi dan Pengingat
- Pengingat harian untuk kebiasaan tertentu
- Pengingat khusus untuk kebiasaan dengan frekuensi tertentu
- Notifikasi ketika streak mencapai angka tertentu (3, 7, 14, 30, 50, 100 hari)
- Notifikasi saat streak reset

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Database**: Isar Database (NoSQL, high performance)
- **UI Design**: Material 3 Design
- **Charts**: fl_chart
- **Date Formatting**: intl package

## 📱 Struktur Aplikasi

### Bottom Navigation
- **Home**: Daftar kebiasaan hari ini
- **Statistik**: Grafik dan analisis data
- **Pengaturan**: Arsip dan manajemen kategori

### Database Schema

#### Category
- `id`: Primary key
- `name`: Nama kategori (unique)
- `color`: Warna kategori (hex/int)
- `icon`: Nama ikon
- `createdAt`: Tanggal dibuat

#### Habit
- `id`: Primary key
- `title`: Judul kebiasaan
- `description`: Deskripsi (opsional)
- `categoryId`: Foreign key ke Category
- `isArchived`: Status arsip (boolean)
- `createdDate`: Tanggal dibuat

#### HabitLog
- `id`: Primary key
- `habitId`: Foreign key ke Habit
- `completionDate`: Tanggal penyelesaian

## 🏗️ Arsitektur Proyek

```
lib/
├── core/
│   ├── constants/          # Konstanta aplikasi
│   └── database/           # Konfigurasi database
├── features/
│   ├── home/              # Halaman utama
│   ├── stats/             # Halaman statistik
│   └── settings/          # Halaman pengaturan
└── shared/
    ├── models/            # Model data
    ├── providers/         # State management
    ├── repositories/      # Data access layer
    └── widgets/           # Widget yang dapat digunakan kembali
```

## 🚀 Cara Menjalankan

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd habitual_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate kode Isar**
   ```bash
   dart run build_runner build
   ```

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## 📋 Requirements

- Flutter SDK ≥ 3.8.1
- Dart SDK ≥ 3.8.0
- Android Studio / VS Code
- Android SDK (untuk Android)
- Xcode (untuk iOS)

## 🎯 Cara Penggunaan

1. **Tambah Kategori**: Buka Pengaturan → Kelola Kategori → Tambah kategori baru
2. **Tambah Kebiasaan**: Di halaman Home, tap tombol + untuk menambah kebiasaan
3. **Tandai Selesai**: Centang checkbox di samping kebiasaan untuk menandai selesai
4. **Lihat Statistik**: Buka tab Statistik untuk melihat progress Anda
5. **Arsip Kebiasaan**: Edit kebiasaan dan pilih "Arsipkan" untuk menyembunyikan tanpa menghapus data

## 🤝 Kontribusi

Kontribusi selalu diterima! Silakan buat issue atau pull request.

## 📄 Lisensi

Proyek ini menggunakan lisensi MIT. Lihat file [LICENSE](LICENSE) untuk detail.

---

**Dibuat dengan ❤️ menggunakan Flutter**
