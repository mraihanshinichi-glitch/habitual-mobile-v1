# 🔧 Backup & Restore Fix

## **🐛 Masalah yang Diperbaiki:**

### 1. **File Backup Tidak Ditemukan**
**Problem**: File backup disimpan di `getApplicationDocumentsDirectory()` yang tidak accessible via file manager
**Fix**: Menggunakan `getExternalStorageDirectory()` dengan fallback ke app documents directory

### 2. **Tidak Ada Opsi Restore**
**Problem**: UI hanya menampilkan "Info Backup" bukan restore yang sebenarnya
**Fix**: Menambahkan button "Pulihkan dari Backup" yang functional

### 3. **Storage Approach Inconsistent**
**Problem**: Backup service masih menggunakan `box.put()` padahal sudah fix ke index-based
**Fix**: Updated restore method untuk menggunakan `box.add()` untuk konsistensi

## **✅ Fixes Applied:**

### **1. Enhanced Backup File Storage**
```dart
// BEFORE ❌ - Not accessible via file manager
final directory = await getApplicationDocumentsDirectory();

// AFTER ✅ - Accessible via file manager
Directory? directory;
try {
  directory = await getExternalStorageDirectory(); // Accessible!
} catch (e) {
  directory = await getApplicationDocumentsDirectory(); // Fallback
}
```

**Lokasi File Backup:**
- **Primary**: `Android/data/com.example.habitual_mobile/files/`
- **Fallback**: App documents directory
- **Format**: `habitual_backup_[timestamp].json`

### **2. Added Functional Restore Button**
```dart
// BEFORE ❌ - Only "Info Backup" button
OutlinedButton.icon(
  onPressed: _showBackupInfo,
  label: const Text('Info Backup'),
)

// AFTER ✅ - Functional restore + info button
OutlinedButton.icon(
  onPressed: _restoreFromBackup,
  label: const Text('Pulihkan dari Backup'),
)
TextButton.icon(
  onPressed: _showBackupInfo,
  label: const Text('Info Backup'),
)
```

### **3. Enhanced Restore Functionality**
```dart
Future<void> _restoreFromBackup() async {
  // Pick most recent backup file automatically
  final backupPath = await _backupService.pickBackupFile();
  
  if (backupPath == null) {
    // Show "no backup found" message
    return;
  }

  // Read and validate backup
  final backup = await _backupService.readBackupFromPath(backupPath);
  final stats = await _backupService.getBackupStats(backup);
  
  // Show confirmation dialog with stats
  final confirmed = await _showRestoreConfirmation(stats, backupPath);
  
  if (confirmed) {
    // Restore data
    await _backupService.restoreFromBackup(backup);
    
    // Refresh all providers
    ref.invalidate(habitsProvider);
    ref.invalidate(categoryProvider);
    ref.invalidate(statsProvider);
  }
}
```

### **4. Fixed Restore Storage Approach**
```dart
// BEFORE ❌ - Using box.put() (key-based)
await databaseService.categoriesBox.put(i, category);
await databaseService.habitsBox.put(i, habit);
await databaseService.habitLogsBox.put(i, log);

// AFTER ✅ - Using box.add() (index-based)
await databaseService.categoriesBox.add(category);
await databaseService.habitsBox.add(habit);
await databaseService.habitLogsBox.add(log);
```

### **5. Enhanced Backup Discovery**
```dart
Future<List<String>> getAvailableBackups() async {
  // Check both external storage and app documents directory
  final directories = <Directory>[];
  
  try {
    final externalDir = await getExternalStorageDirectory();
    if (externalDir != null) directories.add(externalDir);
  } catch (e) { /* handle */ }
  
  try {
    final appDir = await getApplicationDocumentsDirectory();
    directories.add(appDir);
  } catch (e) { /* handle */ }
  
  // Search all directories for backup files
  // Return list of backup file paths
}

Future<String?> pickBackupFile() async {
  // Get all backups and sort by modification time
  // Return most recent backup
}
```

### **6. Enhanced Debug Logging**
Added comprehensive debug logging:
- Backup file save location
- Restore process steps
- Category/habit/log counts
- Error messages

## **🎯 Features Now Working:**

### **Backup Features:**
1. ✅ **Create Backup**: Saves to external storage (accessible via file manager)
2. ✅ **File Location**: Shows full path in success message
3. ✅ **File Format**: JSON format with proper indentation
4. ✅ **Timestamp**: Each backup has unique timestamp in filename
5. ✅ **Complete Data**: Includes all categories, habits, and logs

### **Restore Features:**
1. ✅ **Auto-Select**: Automatically picks most recent backup
2. ✅ **Confirmation Dialog**: Shows backup stats before restore
3. ✅ **File Info**: Displays backup filename in confirmation
4. ✅ **Data Validation**: Validates backup format before restore
5. ✅ **Provider Refresh**: Automatically refreshes all data after restore
6. ✅ **Error Handling**: Clear error messages if restore fails

### **UI Improvements:**
1. ✅ **Restore Button**: Functional "Pulihkan dari Backup" button
2. ✅ **Info Button**: Separate "Info Backup" button for information
3. ✅ **Loading States**: Shows loading indicator during operations
4. ✅ **Success Messages**: Clear feedback after backup/restore
5. ✅ **Error Messages**: Helpful error messages with details

## **📱 How to Use:**

### **Create Backup:**
1. Settings → Backup & Restore
2. Click "Buat Backup"
3. Wait for success message
4. Note the file path shown in message
5. Find file in file manager at shown location

### **Restore from Backup:**
1. Settings → Backup & Restore
2. Click "Pulihkan dari Backup"
3. Review backup stats in confirmation dialog
4. Click "Pulihkan" to confirm
5. Wait for restore to complete
6. App data will be refreshed automatically

### **Find Backup Files:**
**Via File Manager:**
- Navigate to: `Android/data/com.example.habitual_mobile/files/`
- Look for files named: `habitual_backup_[timestamp].json`

**Via ADB (for debugging):**
```bash
adb shell ls /storage/emulated/0/Android/data/com.example.habitual_mobile/files/
```

## **🔍 Debug Console Output:**

### **Backup:**
```
DEBUG: Backup saved to: /storage/emulated/0/Android/data/.../habitual_backup_1234567890.json
```

### **Restore:**
```
DEBUG: Starting restore process...
DEBUG: Cleared existing data
DEBUG: Restored 5 categories
DEBUG: Restored 10 habits
DEBUG: Restored 50 habit logs
DEBUG: Restore completed successfully
```

### **Backup Discovery:**
```
DEBUG: Found 3 backup files
```

## **🚨 Important Notes:**

### **File Permissions:**
- App needs storage permissions to access external storage
- If external storage not available, falls back to app documents directory

### **Backup File Location:**
- External storage is accessible via file manager
- Files can be copied, shared, or backed up to cloud
- Files persist even if app is uninstalled (on external storage)

### **Restore Behavior:**
- Restore **replaces all existing data**
- Action cannot be undone
- Always create backup before restore
- Confirmation dialog shows what will be restored

---
**Status**: Backup & Restore fully functional! 🎯✅
**Date**: December 18, 2025
**Key Fixes**: 
- External storage for accessible backups
- Functional restore button
- Index-based storage consistency
- Enhanced error handling and feedback