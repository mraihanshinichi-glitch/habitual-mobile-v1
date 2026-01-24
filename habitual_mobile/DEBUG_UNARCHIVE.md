# Debug Unarchive Issue

## 🐛 **Masalah Unarchive yang Diperbaiki:**

### **Root Cause Analysis:**
1. **Key Mismatch**: `habit.key` tidak selalu sesuai dengan key database yang sebenarnya
2. **Hive Key vs Index**: Hive menggunakan key dan index yang berbeda
3. **Error Handling**: Tidak ada fallback jika key pertama gagal

### **🔧 Fixes Applied:**

#### 1. **Enhanced Archive Method**
```dart
// SEBELUM ❌
final habit = box.get(key);
if (habit != null) {
  habit.isArchived = isArchived;
  await box.put(key, habit);
}

// SESUDAH ✅
Habit? habit = box.get(key);
if (habit == null && key < box.length) {
  habit = box.getAt(key);  // Fallback to index
  if (habit != null) {
    habit.isArchived = isArchived;
    await box.putAt(key, habit);  // Use putAt for index
  }
} else if (habit != null) {
  habit.isArchived = isArchived;
  await box.put(key, habit);  // Use put for key
}
```

#### 2. **Double Fallback Strategy**
```dart
// Try with habitKey first
bool success = await archiveHabit(habitKey, false);

// If failed, try with index
if (!success && habitKey != index) {
  success = await archiveHabit(index, false);
}
```

#### 3. **Enhanced Error Handling**
```dart
try {
  // Archive operation with fallback
} catch (e) {
  ScaffoldMessenger.showSnackBar(
    SnackBar(content: Text('Error: $e'))
  );
}
```

#### 4. **Dual Provider Refresh**
```dart
if (success) {
  ref.invalidate(archivedHabitsProvider);  // Refresh archived list
  ref.invalidate(habitsProvider);          // Refresh main list
}
```

## 🎯 **Testing Steps:**

### **Test Scenario 1: Basic Unarchive**
1. ✅ Buat kebiasaan baru
2. ✅ Arsipkan kebiasaan (Edit → Arsipkan)
3. ✅ Buka Settings → Kebiasaan Terarsip
4. ✅ Tap kebiasaan → Pilih "Aktifkan Kembali"
5. ✅ **Expected**: Success message + kebiasaan hilang dari daftar arsip
6. ✅ Kembali ke Home → **Expected**: Kebiasaan muncul di daftar utama

### **Test Scenario 2: Multiple Archive/Unarchive**
1. ✅ Buat 3 kebiasaan
2. ✅ Arsipkan semua
3. ✅ Unarchive satu per satu
4. ✅ **Expected**: Setiap unarchive berhasil dan kebiasaan pindah ke daftar utama

### **Test Scenario 3: Error Recovery**
1. ✅ Jika ada error, akan muncul pesan error yang jelas
2. ✅ Aplikasi tidak crash
3. ✅ Bisa retry operation

## 🚨 **Debug Commands:**

### **Hot Reload:**
```bash
r  # Hot reload untuk apply changes
R  # Hot restart jika perlu reset state
```

### **Manual Verification:**
1. **Check Archive Status**: Pastikan `isArchived` berubah di database
2. **Check Provider Refresh**: Pastikan kedua provider ter-refresh
3. **Check Error Messages**: Lihat console untuk error details

### **Expected Behavior:**
- ✅ **Immediate Response**: Unarchive langsung berhasil
- ✅ **UI Update**: Kebiasaan hilang dari daftar arsip
- ✅ **List Refresh**: Kebiasaan muncul di daftar utama
- ✅ **Success Message**: Snackbar konfirmasi muncul

## 🔍 **Troubleshooting:**

### **Jika Masih Gagal:**
1. **Hot Restart**: Tekan `R` di terminal Flutter
2. **Check Console**: Lihat error messages di debug console
3. **Verify Data**: Pastikan kebiasaan benar-benar ada di database
4. **Test Simple Case**: Coba dengan 1 kebiasaan saja dulu

### **Debug Prints (Optional):**
Tambahkan di `archiveHabit` method:
```dart
print('DEBUG: Trying to unarchive key: $key');
print('DEBUG: Habit found: ${habit != null}');
print('DEBUG: Archive status changed: ${habit?.isArchived}');
```

---
**Status**: Enhanced unarchive with double fallback strategy! 🎯