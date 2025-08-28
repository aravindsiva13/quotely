// core/services/storage_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/user.dart';
import '../../data/models/customer.dart';
import '../../data/models/document.dart';
import '../../data/models/item.dart';
import '../../data/models/dashboard_stats.dart';

class StorageService {
  static const String _userFileName = 'user_data.json';
  static const String _customersFileName = 'customers_data.json';
  static const String _documentsFileName = 'documents_data.json';
  static const String _itemsFileName = 'items_data.json';
  static const String _settingsFileName = 'app_settings.json';
  
  static Directory? _appDocumentsDirectory;

  /// Initialize the storage service
  static Future<void> initialize() async {
    try {
      _appDocumentsDirectory = await getApplicationDocumentsDirectory();
      
      // Create app-specific directories
      final directories = [
        Directory('${_appDocumentsDirectory!.path}/data'),
        Directory('${_appDocumentsDirectory!.path}/backups'),
        Directory('${_appDocumentsDirectory!.path}/pdfs'),
        Directory('${_appDocumentsDirectory!.path}/temp'),
      ];
      
      for (final dir in directories) {
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      }
      
      debugPrint('✅ StorageService initialized');
    } catch (e) {
      debugPrint('❌ StorageService initialization failed: $e');
      throw Exception('Failed to initialize storage service: $e');
    }
  }

  /// Get the data directory path
  static String get _dataPath => '${_appDocumentsDirectory!.path}/data';

  // ==================== USER DATA ====================

  /// Save user data
  static Future<void> saveUser(User user) async {
    try {
      final file = File('$_dataPath/$_userFileName');
      final jsonData = jsonEncode(user.toJson());
      await file.writeAsString(jsonData);
      debugPrint('User data saved');
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Load user data
  static Future<User?> loadUser() async {
    try {
      final file = File('$_dataPath/$_userFileName');
      if (!await file.exists()) return null;
      
      final jsonData = await file.readAsString();
      final userData = jsonDecode(jsonData) as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      debugPrint('Failed to load user data: $e');
      return null;
    }
  }

  /// Delete user data
  static Future<void> deleteUser() async {
    try {
      final file = File('$_dataPath/$_userFileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  // ==================== CUSTOMERS DATA ====================

  /// Save customers list
  static Future<void> saveCustomers(List<Customer> customers) async {
    try {
      final file = File('$_dataPath/$_customersFileName');
      final jsonData = jsonEncode(customers.map((c) => c.toJson()).toList());
      await file.writeAsString(jsonData);
      debugPrint('Customers data saved (${customers.length} customers)');
    } catch (e) {
      throw Exception('Failed to save customers data: $e');
    }
  }

  /// Load customers list
  static Future<List<Customer>> loadCustomers() async {
    try {
      final file = File('$_dataPath/$_customersFileName');
      if (!await file.exists()) return [];
      
      final jsonData = await file.readAsString();
      final customersData = jsonDecode(jsonData) as List;
      return customersData.map((c) => Customer.fromJson(c)).toList();
    } catch (e) {
      debugPrint('Failed to load customers data: $e');
      return [];
    }
  }

  // ==================== DOCUMENTS DATA ====================

  /// Save documents list
  static Future<void> saveDocuments(List<Document> documents) async {
    try {
      final file = File('$_dataPath/$_documentsFileName');
      final jsonData = jsonEncode(documents.map((d) => d.toJson()).toList());
      await file.writeAsString(jsonData);
      debugPrint('Documents data saved (${documents.length} documents)');
    } catch (e) {
      throw Exception('Failed to save documents data: $e');
    }
  }

  /// Load documents list
  static Future<List<Document>> loadDocuments() async {
    try {
      final file = File('$_dataPath/$_documentsFileName');
      if (!await file.exists()) return [];
      
      final jsonData = await file.readAsString();
      final documentsData = jsonDecode(jsonData) as List;
      return documentsData.map((d) => Document.fromJson(d)).toList();
    } catch (e) {
      debugPrint('Failed to load documents data: $e');
      return [];
    }
  }

  // ==================== ITEMS DATA ====================

  /// Save items list
  static Future<void> saveItems(List<Item> items) async {
    try {
      final file = File('$_dataPath/$_itemsFileName');
      final jsonData = jsonEncode(items.map((i) => i.toJson()).toList());
      await file.writeAsString(jsonData);
      debugPrint('Items data saved (${items.length} items)');
    } catch (e) {
      throw Exception('Failed to save items data: $e');
    }
  }

  /// Load items list
  static Future<List<Item>> loadItems() async {
    try {
      final file = File('$_dataPath/$_itemsFileName');
      if (!await file.exists()) return [];
      
      final jsonData = await file.readAsString();
      final itemsData = jsonDecode(jsonData) as List;
      return itemsData.map((i) => Item.fromJson(i)).toList();
    } catch (e) {
      debugPrint('Failed to load items data: $e');
      return [];
    }
  }

  // ==================== APP SETTINGS ====================

  /// Save app settings
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final file = File('$_dataPath/$_settingsFileName');
      final jsonData = jsonEncode(settings);
      await file.writeAsString(jsonData);
      debugPrint('App settings saved');
    } catch (e) {
      throw Exception('Failed to save app settings: $e');
    }
  }

  /// Load app settings
  static Future<Map<String, dynamic>> loadAppSettings() async {
    try {
      final file = File('$_dataPath/$_settingsFileName');
      if (!await file.exists()) return {};
      
      final jsonData = await file.readAsString();
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to load app settings: $e');
      return {};
    }
  }

  // ==================== BACKUP & RESTORE ====================

  /// Create a complete backup of all app data
  static Future<String> createBackup() async {
    try {
      final backupData = <String, dynamic>{};
      
      // Load all data
      final user = await loadUser();
      final customers = await loadCustomers();
      final documents = await loadDocuments();
      final items = await loadItems();
      final settings = await loadAppSettings();
      
      // Compile backup data
      backupData['user'] = user?.toJson();
      backupData['customers'] = customers.map((c) => c.toJson()).toList();
      backupData['documents'] = documents.map((d) => d.toJson()).toList();
      backupData['items'] = items.map((i) => i.toJson()).toList();
      backupData['settings'] = settings;
      backupData['backup_date'] = DateTime.now().toIso8601String();
      backupData['app_version'] = '1.0.0'; // You can get this from package_info
      
      // Save backup file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFileName = 'backup_$timestamp.json';
      final backupFile = File('${_appDocumentsDirectory!.path}/backups/$backupFileName');
      
      await backupFile.writeAsString(jsonEncode(backupData));
      
      debugPrint('Backup created: $backupFileName');
      return backupFile.path;
      
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Restore data from backup file
  static Future<void> restoreFromBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }
      
      final jsonData = await backupFile.readAsString();
      final backupData = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Validate backup data
      if (!_isValidBackup(backupData)) {
        throw Exception('Invalid backup file format');
      }
      
      // Clear existing data first
      await clearAllData();
      
      // Restore user data
      if (backupData['user'] != null) {
        final user = User.fromJson(backupData['user']);
        await saveUser(user);
      }
      
      // Restore customers
      if (backupData['customers'] != null) {
        final customers = (backupData['customers'] as List)
            .map((c) => Customer.fromJson(c))
            .toList();
        await saveCustomers(customers);
      }
      
      // Restore documents
      if (backupData['documents'] != null) {
        final documents = (backupData['documents'] as List)
            .map((d) => Document.fromJson(d))
            .toList();
        await saveDocuments(documents);
      }
      
      // Restore items
      if (backupData['items'] != null) {
        final items = (backupData['items'] as List)
            .map((i) => Item.fromJson(i))
            .toList();
        await saveItems(items);
      }
      
      // Restore settings
      if (backupData['settings'] != null) {
        await saveAppSettings(backupData['settings']);
      }
      
      debugPrint('Data restored from backup successfully');
      
    } catch (e) {
      throw Exception('Failed to restore from backup: $e');
    }
  }

  /// Validate backup data format
  static bool _isValidBackup(Map<String, dynamic> backupData) {
    return backupData.containsKey('backup_date') &&
           backupData.containsKey('app_version');
  }

  /// Get list of available backups
  static Future<List<BackupInfo>> getAvailableBackups() async {
    try {
      final backupsDir = Directory('${_appDocumentsDirectory!.path}/backups');
      if (!await backupsDir.exists()) return [];
      
      final backupFiles = await backupsDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();
      
      final backups = <BackupInfo>[];
      
      for (final file in backupFiles) {
        try {
          final jsonData = await file.readAsString();
          final backupData = jsonDecode(jsonData) as Map<String, dynamic>;
          
          final backupInfo = BackupInfo(
            fileName: file.path.split('/').last,
            filePath: file.path,
            date: DateTime.parse(backupData['backup_date']),
            appVersion: backupData['app_version'] ?? 'Unknown',
            fileSize: await file.length(),
            customerCount: (backupData['customers'] as List?)?.length ?? 0,
            documentCount: (backupData['documents'] as List?)?.length ?? 0,
            itemCount: (backupData['items'] as List?)?.length ?? 0,
          );
          
          backups.add(backupInfo);
        } catch (e) {
          debugPrint('Failed to read backup file ${file.path}: $e');
        }
      }
      
      // Sort by date (newest first)
      backups.sort((a, b) => b.date.compareTo(a.date));
      
      return backups;
      
    } catch (e) {
      debugPrint('Failed to get available backups: $e');
      return [];
    }
  }

  /// Delete a backup file
  static Future<void> deleteBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
        debugPrint('Backup deleted: $backupPath');
      }
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }

  // ==================== DATA MANAGEMENT ====================

  /// Clear all stored data
  static Future<void> clearAllData() async {
    try {
      final files = [
        File('$_dataPath/$_userFileName'),
        File('$_dataPath/$_customersFileName'),
        File('$_dataPath/$_documentsFileName'),
        File('$_dataPath/$_itemsFileName'),
        File('$_dataPath/$_settingsFileName'),
      ];
      
      for (final file in files) {
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      debugPrint('All data cleared');
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  /// Get storage statistics
  static Future<StorageStats> getStorageStats() async {
    try {
      final dataDir = Directory(_dataPath);
      if (!await dataDir.exists()) {
        return StorageStats(
          totalSize: 0,
          userDataSize: 0,
          customersDataSize: 0,
          documentsDataSize: 0,
          itemsDataSize: 0,
          backupsSize: 0,
        );
      }
      
      final files = await dataDir.list().cast<File>().toList();
      int totalSize = 0;
      int userDataSize = 0;
      int customersDataSize = 0;
      int documentsDataSize = 0;
      int itemsDataSize = 0;
      
      for (final file in files) {
        final size = await file.length();
        totalSize += size;
        
        if (file.path.endsWith(_userFileName)) {
          userDataSize = size;
        } else if (file.path.endsWith(_customersFileName)) {
          customersDataSize = size;
        } else if (file.path.endsWith(_documentsFileName)) {
          documentsDataSize = size;
        } else if (file.path.endsWith(_itemsFileName)) {
          itemsDataSize = size;
        }
      }
      
      // Calculate backups size
      final backupsDir = Directory('${_appDocumentsDirectory!.path}/backups');
      int backupsSize = 0;
      if (await backupsDir.exists()) {
        final backupFiles = await backupsDir.list().cast<File>().toList();
        for (final file in backupFiles) {
          backupsSize += await file.length();
        }
      }
      
      return StorageStats(
        totalSize: totalSize,
        userDataSize: userDataSize,
        customersDataSize: customersDataSize,
        documentsDataSize: documentsDataSize,
        itemsDataSize: itemsDataSize,
        backupsSize: backupsSize,
      );
      
    } catch (e) {
      throw Exception('Failed to get storage stats: $e');
    }
  }

  // ==================== EXPORT/IMPORT ====================

  /// Export data to external file (for sharing)
  static Future<String> exportToFile({
    required String fileName,
    bool includeCustomers = true,
    bool includeDocuments = true,
    bool includeItems = true,
  }) async {
    try {
      final exportData = <String, dynamic>{};
      
      if (includeCustomers) {
        final customers = await loadCustomers();
        exportData['customers'] = customers.map((c) => c.toJson()).toList();
      }
      
      if (includeDocuments) {
        final documents = await loadDocuments();
        exportData['documents'] = documents.map((d) => d.toJson()).toList();
      }
      
      if (includeItems) {
        final items = await loadItems();
        exportData['items'] = items.map((i) => i.toJson()).toList();
      }
      
      exportData['export_date'] = DateTime.now().toIso8601String();
      exportData['app_version'] = '1.0.0';
      
      // Save to Downloads or external directory
      final externalDir = await getExternalStorageDirectory();
      final exportFile = File('${externalDir?.path ?? _appDocumentsDirectory!.path}/$fileName.json');
      
      await exportFile.writeAsString(jsonEncode(exportData));
      
      debugPrint('Data exported to: ${exportFile.path}');
      return exportFile.path;
      
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Import data from external file
  static Future<ImportResult> importFromFile(String filePath) async {
    try {
      final importFile = File(filePath);
      if (!await importFile.exists()) {
        throw Exception('Import file not found');
      }
      
      final jsonData = await importFile.readAsString();
      final importData = jsonDecode(jsonData) as Map<String, dynamic>;
      
      int customersImported = 0;
      int documentsImported = 0;
      int itemsImported = 0;
      
      // Import customers
      if (importData['customers'] != null) {
        final existingCustomers = await loadCustomers();
        final importCustomers = (importData['customers'] as List)
            .map((c) => Customer.fromJson(c))
            .toList();
        
        // Merge with existing data (avoid duplicates by email)
        final existingEmails = existingCustomers.map((c) => c.email).toSet();
        final newCustomers = importCustomers
            .where((c) => !existingEmails.contains(c.email))
            .toList();
        
        if (newCustomers.isNotEmpty) {
          existingCustomers.addAll(newCustomers);
          await saveCustomers(existingCustomers);
          customersImported = newCustomers.length;
        }
      }
      
      // Import documents
      if (importData['documents'] != null) {
        final existingDocuments = await loadDocuments();
        final importDocuments = (importData['documents'] as List)
            .map((d) => Document.fromJson(d))
            .toList();
        
        // Merge with existing data (avoid duplicates by number)
        final existingNumbers = existingDocuments.map((d) => d.number).toSet();
        final newDocuments = importDocuments
            .where((d) => !existingNumbers.contains(d.number))
            .toList();
        
        if (newDocuments.isNotEmpty) {
          existingDocuments.addAll(newDocuments);
          await saveDocuments(existingDocuments);
          documentsImported = newDocuments.length;
        }
      }
      
      // Import items
      if (importData['items'] != null) {
        final existingItems = await loadItems();
        final importItems = (importData['items'] as List)
            .map((i) => Item.fromJson(i))
            .toList();
        
        // Merge with existing data (avoid duplicates by name)
        final existingNames = existingItems.map((i) => i.name).toSet();
        final newItems = importItems
            .where((i) => !existingNames.contains(i.name))
            .toList();
        
        if (newItems.isNotEmpty) {
          existingItems.addAll(newItems);
          await saveItems(existingItems);
          itemsImported = newItems.length;
        }
      }
      
      return ImportResult(
        success: true,
        customersImported: customersImported,
        documentsImported: documentsImported,
        itemsImported: itemsImported,
      );
      
    } catch (e) {
      return ImportResult(
        success: false,
        error: 'Failed to import data: $e',
      );
    }
  }
}

// ==================== DATA MODELS ====================

class BackupInfo {
  final String fileName;
  final String filePath;
  final DateTime date;
  final String appVersion;
  final int fileSize;
  final int customerCount;
  final int documentCount;
  final int itemCount;

  BackupInfo({
    required this.fileName,
    required this.filePath,
    required this.date,
    required this.appVersion,
    required this.fileSize,
    required this.customerCount,
    required this.documentCount,
    required this.itemCount,
  });

  String get formattedSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class StorageStats {
  final int totalSize;
  final int userDataSize;
  final int customersDataSize;
  final int documentsDataSize;
  final int itemsDataSize;
  final int backupsSize;

  StorageStats({
    required this.totalSize,
    required this.userDataSize,
    required this.customersDataSize,
    required this.documentsDataSize,
    required this.itemsDataSize,
    required this.backupsSize,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedTotalSize => _formatSize(totalSize);
  String get formattedUserDataSize => _formatSize(userDataSize);
  String get formattedCustomersDataSize => _formatSize(customersDataSize);
  String get formattedDocumentsDataSize => _formatSize(documentsDataSize);
  String get formattedItemsDataSize => _formatSize(itemsDataSize);
  String get formattedBackupsSize => _formatSize(backupsSize);
}

class ImportResult {
  final bool success;
  final int customersImported;
  final int documentsImported;
  final int itemsImported;
  final String? error;

  ImportResult({
    required this.success,
    this.customersImported = 0,
    this.documentsImported = 0,
    this.itemsImported = 0,
    this.error,
  });

  int get totalImported => customersImported + documentsImported + itemsImported;
}