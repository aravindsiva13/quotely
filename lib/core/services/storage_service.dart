// // core/services/storage_service.dart - INTEGRATED WITH REPOSITORIES
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:path_provider/path_provider.dart';
// import '../../data/models/user.dart';
// import '../../data/models/customer.dart';
// import '../../data/models/document.dart';
// import '../../data/models/item.dart';
// import '../../data/models/dashboard_stats.dart';

// class StorageService {
//   static const String _userFileName = 'user_data.json';
//   static const String _customersFileName = 'customers_data.json';
//   static const String _documentsFileName = 'documents_data.json';
//   static const String _itemsFileName = 'items_data.json';
//   static const String _settingsFileName = 'app_settings.json';
  
//   static Directory? _appDocumentsDirectory;
//   static bool _isInitialized = false;

//   /// Initialize the storage service
//   static Future<void> initialize() async {
//     if (_isInitialized) return;
    
//     try {
//       _appDocumentsDirectory = await getApplicationDocumentsDirectory();
      
//       // Create app-specific directories
//       final directories = [
//         Directory('${_appDocumentsDirectory!.path}/data'),
//         Directory('${_appDocumentsDirectory!.path}/backups'),
//         Directory('${_appDocumentsDirectory!.path}/pdfs'),
//         Directory('${_appDocumentsDirectory!.path}/temp'),
//       ];
      
//       for (final dir in directories) {
//         if (!await dir.exists()) {
//           await dir.create(recursive: true);
//         }
//       }
      
//       _isInitialized = true;
//       debugPrint('✅ StorageService initialized');
//     } catch (e) {
//       debugPrint('❌ StorageService initialization failed: $e');
//       throw Exception('Failed to initialize storage service: $e');
//     }
//   }

//   /// Ensure storage is initialized
//   static Future<void> _ensureInitialized() async {
//     if (!_isInitialized) {
//       await initialize();
//     }
//   }

//   /// Get the data directory path
//   static String get _dataPath => '${_appDocumentsDirectory!.path}/data';

//   // ==================== USER DATA ====================

//   /// Save user data
//   static Future<void> saveUser(User user) async {
//     try {
//       await _ensureInitialized();
//       final file = File('$_dataPath/$_userFileName');
//       final jsonData = jsonEncode(user.toJson());
//       await file.writeAsString(jsonData);
//       debugPrint('User data saved');
//     } catch (e) {
//       throw Exception('Failed to save user data: $e');
//     }
//   }

//   /// Load user data
//   static Future<User?> loadUser() async {
//     try {
//       await _ensureInitialized();
//       final file = File('$_dataPath/$_userFileName');
//       if (!await file.exists()) return null;
      
//       final jsonData = await file.readAsString();
//       final userData = jsonDecode(jsonData) as Map<String, dynamic>;
//       return User.fromJson(userData);
//     } catch (e) {
//       debugPrint('Failed to load user data: $e');
//       return null;
//     }
//   }

//   /// Delete user data
//   static Future<void> deleteUser() async {
//     try {
//       await _ensureInitialized();
//       final file = File('$_dataPath/$_userFileName');
//       if (await file.exists()) {
//         await file.delete();
//       }
//     } catch (e) {
//       throw Exception('Failed to delete user data: $e');
//     }
//   }

//   // ==================== CUSTOMERS DATA ====================

//   /// Save customers list
//   static Future<void> saveCustomers(List<Customer> customers) async {
//     try {
//       await _ensureInitialized();
//       final file = File('$_dataPath/$_customersFileName');
//       final jsonData = jsonEncode(customers.map((c) => c.toJson()).toList());
//       await file.writeAsString(jsonData);
//       debugPrint('Customers data saved (${customers.length} customers)');
//     } catch (e) {
//       throw Exception('Failed to save customers data: $e');
//     }
//   }

//   /// Load customers list
//   static Future<List<Customer>> loadCustomers() async {
//     try {
//       await _ensureInitialized();
//       final file = File('$_dataPath/$_customersFileName');
//       if (!await file.exists()) return [];
      
//       final jsonData = await file.readAsString();
//       final customersData = jsonDecode(jsonData) as List;
//       return customersData.map((c) => Customer.fromJson(c)).toList();
//     } catch (e) {
//       debugPrint('Failed to load customers data: $e');
//       return [];
//     }
//   }

//   // ==================== DOCUMENTS DATA ====================

//   /// Save documents list
//   static Future<void> saveDocuments(List<Document> documents) async {
//     try {
//       await _ensureInitialized();
//       final file = File('$_dataPath/$_documentsFileName');
//       final jsonData = jsonEncode(documents.map((d) => d.toJson()).toList());
//       await file.writeAsString(jsonData);
//       debugPrint('Documents data saved (${documents.length} documents)');
//     } catch (e) {
//       throw Exception('Failed to save documents data: $e');
//     }
//   }

//   /// Load documents list
//   static Future<List<Document>> loadDocuments() async {
//     try {
//       await _ensureInitialized();
//       final file = File('$_dataPath/$_documentsFileName');
//       if (!await file.exists()) return [];
      
//       final jsonData = await file.readAsString();
//       final documentsData = jsonDecode(jsonData) as List;
//       return documentsData.map((d) => Document.fromJson(d)).toList();
//     } catch (e) {
//       debugPrint('Failed to load documents data: $e');
//       return [];
//     }
//   }

//   // ==================== ITEMS DATA ====================

//   /// Save items list
//   static Future<void> saveItems(List<Item> items) async {
//     try {
//       await _ensureInitialized();
//       final file = File('$_dataPath/$_itemsFileName');
//       final jsonData = jsonEncode(items.map((i) => i.toJson()).toList());
//       await file.writeAsString(jsonData);
//       debugPrint('Items data saved (${items.length} items)');
//     } catch (e) {
//       throw Exception('Failed to save items data: $e');
//     }
//   }

//   /// Load items list
//   static Future<List<Item>> loadItems() async {
//     try {
//       await _ensureInitialized();
//       final file = File('$_dataPath/$_itemsFileName');
//       if (!await file.exists()) return [];
      
//       final jsonData = await file.readAsString();
//       final itemsData = jsonDecode(jsonData) as List;
//       return itemsData.map((i) => Item.fromJson(i)).toList();
//     } catch (e) {
//       debugPrint('Failed to load items data: $e');
//       return [];
//     }
//   }

//   // ==================== APP SETTINGS ====================

//   /// Save app settings
//   static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
//     try {
//       await _ensureInitialized();
//       final file = File('$_dataPath/$_settingsFileName');
//       final jsonData = jsonEncode(settings);
//       await file.writeAsString(jsonData);
//       debugPrint('App settings saved');
//     } catch (e) {
//       throw Exception('Failed to save app settings: $e');
//     }
//   }

//   /// Load app settings
//   static Future<Map<String, dynamic>> loadAppSettings() async {
//     try {
//       await _ensureInitialized();
//       final file = File('$_dataPath/$_settingsFileName');
//       if (!await file.exists()) return {};
      
//       final jsonData = await file.readAsString();
//       return jsonDecode(jsonData) as Map<String, dynamic>;
//     } catch (e) {
//       debugPrint('Failed to load app settings: $e');
//       return {};
//     }
//   }

//   // ==================== BACKUP & RESTORE ====================

//   /// Create a complete backup of all app data
//   static Future<String> createBackup() async {
//     try {
//       await _ensureInitialized();
//       final backupData = <String, dynamic>{};
      
//       // Load all data
//       final user = await loadUser();
//       final customers = await loadCustomers();
//       final documents = await loadDocuments();
//       final items = await loadItems();
//       final settings = await loadAppSettings();
      
//       // Compile backup data
//       backupData['user'] = user?.toJson();
//       backupData['customers'] = customers.map((c) => c.toJson()).toList();
//       backupData['documents'] = documents.map((d) => d.toJson()).toList();
//       backupData['items'] = items.map((i) => i.toJson()).toList();
//       backupData['settings'] = settings;
//       backupData['backup_date'] = DateTime.now().toIso8601String();
//       backupData['app_version'] = '1.0.0';
      
//       // Save backup file
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final backupFileName = 'backup_$timestamp.json';
//       final backupFile = File('${_appDocumentsDirectory!.path}/backups/$backupFileName');
      
//       await backupFile.writeAsString(jsonEncode(backupData));
      
//       debugPrint('Backup created: $backupFileName');
//       return backupFile.path;
      
//     } catch (e) {
//       throw Exception('Failed to create backup: $e');
//     }
//   }

//   /// Restore data from backup file
//   static Future<void> restoreFromBackup(String backupPath) async {
//     try {
//       await _ensureInitialized();
//       final backupFile = File(backupPath);
//       if (!await backupFile.exists()) {
//         throw Exception('Backup file not found');
//       }
      
//       final jsonData = await backupFile.readAsString();
//       final backupData = jsonDecode(jsonData) as Map<String, dynamic>;
      
//       // Validate backup data
//       if (!_isValidBackup(backupData)) {
//         throw Exception('Invalid backup file format');
//       }
      
//       // Clear existing data first
//       await clearAllData();
      
//       // Restore user data
//       if (backupData['user'] != null) {
//         final user = User.fromJson(backupData['user']);
//         await saveUser(user);
//       }
      
//       // Restore customers
//       if (backupData['customers'] != null) {
//         final customers = (backupData['customers'] as List)
//             .map((c) => Customer.fromJson(c))
//             .toList();
//         await saveCustomers(customers);
//       }
      
//       // Restore documents
//       if (backupData['documents'] != null) {
//         final documents = (backupData['documents'] as List)
//             .map((d) => Document.fromJson(d))
//             .toList();
//         await saveDocuments(documents);
//       }
      
//       // Restore items
//       if (backupData['items'] != null) {
//         final items = (backupData['items'] as List)
//             .map((i) => Item.fromJson(i))
//             .toList();
//         await saveItems(items);
//       }
      
//       // Restore settings
//       if (backupData['settings'] != null) {
//         await saveAppSettings(backupData['settings']);
//       }
      
//       debugPrint('Data restored from backup successfully');
      
//     } catch (e) {
//       throw Exception('Failed to restore from backup: $e');
//     }
//   }

//   /// Validate backup data format
//   static bool _isValidBackup(Map<String, dynamic> backupData) {
//     return backupData.containsKey('backup_date') &&
//            backupData.containsKey('app_version');
//   }

//   /// Get list of available backups
//   static Future<List<BackupInfo>> getAvailableBackups() async {
//     try {
//       await _ensureInitialized();
//       final backupsDir = Directory('${_appDocumentsDirectory!.path}/backups');
//       if (!await backupsDir.exists()) return [];
      
//       final backupFiles = await backupsDir
//           .list()
//           .where((entity) => entity is File && entity.path.endsWith('.json'))
//           .cast<File>()
//           .toList();
      
//       final backups = <BackupInfo>[];
      
//       for (final file in backupFiles) {
//         try {
//           final jsonData = await file.readAsString();
//           final backupData = jsonDecode(jsonData) as Map<String, dynamic>;
          
//           final backupInfo = BackupInfo(
//             fileName: file.path.split('/').last,
//             filePath: file.path,
//             date: DateTime.parse(backupData['backup_date']),
//             appVersion: backupData['app_version'] ?? 'Unknown',
//             fileSize: await file.length(),
//             customerCount: (backupData['customers'] as List?)?.length ?? 0,
//             documentCount: (backupData['documents'] as List?)?.length ?? 0,
//             itemCount: (backupData['items'] as List?)?.length ?? 0,
//           );
          
//           backups.add(backupInfo);
//         } catch (e) {
//           debugPrint('Failed to read backup file ${file.path}: $e');
//         }
//       }
      
//       // Sort by date (newest first)
//       backups.sort((a, b) => b.date.compareTo(a.date));
      
//       return backups;
      
//     } catch (e) {
//       debugPrint('Failed to get available backups: $e');
//       return [];
//     }
//   }

//   /// Delete a backup file
//   static Future<void> deleteBackup(String backupPath) async {
//     try {
//       final backupFile = File(backupPath);
//       if (await backupFile.exists()) {
//         await backupFile.delete();
//         debugPrint('Backup deleted: $backupPath');
//       }
//     } catch (e) {
//       throw Exception('Failed to delete backup: $e');
//     }
//   }

//   // ==================== DATA MANAGEMENT ====================

//   /// Clear all stored data
//   static Future<void> clearAllData() async {
//     try {
//       await _ensureInitialized();
//       final files = [
//         File('$_dataPath/$_userFileName'),
//         File('$_dataPath/$_customersFileName'),
//         File('$_dataPath/$_documentsFileName'),
//         File('$_dataPath/$_itemsFileName'),
//         File('$_dataPath/$_settingsFileName'),
//       ];
      
//       for (final file in files) {
//         if (await file.exists()) {
//           await file.delete();
//         }
//       }
      
//       debugPrint('All data cleared');
//     } catch (e) {
//       throw Exception('Failed to clear all data: $e');
//     }
//   }

//   /// Get storage statistics
//   static Future<StorageStats> getStorageStats() async {
//     try {
//       await _ensureInitialized();
//       final dataDir = Directory(_dataPath);
//       if (!await dataDir.exists()) {
//         return StorageStats(
//           totalSize: 0,
//           userDataSize: 0,
//           customersDataSize: 0,
//           documentsDataSize: 0,
//           itemsDataSize: 0,
//           backupsSize: 0,
//         );
//       }
      
//       final files = await dataDir.list().cast<File>().toList();
//       int totalSize = 0;
//       int userDataSize = 0;
//       int customersDataSize = 0;
//       int documentsDataSize = 0;
//       int itemsDataSize = 0;
      
//       for (final file in files) {
//         final size = await file.length();
//         totalSize += size;
        
//         if (file.path.endsWith(_userFileName)) {
//           userDataSize = size;
//         } else if (file.path.endsWith(_customersFileName)) {
//           customersDataSize = size;
//         } else if (file.path.endsWith(_documentsFileName)) {
//           documentsDataSize = size;
//         } else if (file.path.endsWith(_itemsFileName)) {
//           itemsDataSize = size;
//         }
//       }
      
//       // Calculate backups size
//       final backupsDir = Directory('${_appDocumentsDirectory!.path}/backups');
//       int backupsSize = 0;
//       if (await backupsDir.exists()) {
//         final backupFiles = await backupsDir.list().cast<File>().toList();
//         for (final file in backupFiles) {
//           backupsSize += await file.length();
//         }
//       }
      
//       return StorageStats(
//         totalSize: totalSize,
//         userDataSize: userDataSize,
//         customersDataSize: customersDataSize,
//         documentsDataSize: documentsDataSize,
//         itemsDataSize: itemsDataSize,
//         backupsSize: backupsSize,
//       );
      
//     } catch (e) {
//       throw Exception('Failed to get storage stats: $e');
//     }
//   }

//   // ==================== EXPORT/IMPORT ====================

//   /// Export data to external file (for sharing)
//   static Future<String> exportToFile({
//     required String fileName,
//     bool includeCustomers = true,
//     bool includeDocuments = true,
//     bool includeItems = true,
//   }) async {
//     try {
//       await _ensureInitialized();
//       final exportData = <String, dynamic>{};
      
//       if (includeCustomers) {
//         final customers = await loadCustomers();
//         exportData['customers'] = customers.map((c) => c.toJson()).toList();
//       }
      
//       if (includeDocuments) {
//         final documents = await loadDocuments();
//         exportData['documents'] = documents.map((d) => d.toJson()).toList();
//       }
      
//       if (includeItems) {
//         final items = await loadItems();
//         exportData['items'] = items.map((i) => i.toJson()).toList();
//       }
      
//       exportData['export_date'] = DateTime.now().toIso8601String();
//       exportData['app_version'] = '1.0.0';
      
//       // Save to Downloads or external directory
//       final externalDir = await getExternalStorageDirectory();
//       final exportFile = File('${externalDir?.path ?? _appDocumentsDirectory!.path}/$fileName.json');
      
//       await exportFile.writeAsString(jsonEncode(exportData));
      
//       debugPrint('Data exported to: ${exportFile.path}');
//       return exportFile.path;
      
//     } catch (e) {
//       throw Exception('Failed to export data: $e');
//     }
//   }

//   /// Import data from external file
//   static Future<ImportResult> importFromFile(String filePath) async {
//     try {
//       await _ensureInitialized();
//       final importFile = File(filePath);
//       if (!await importFile.exists()) {
//         throw Exception('Import file not found');
//       }
      
//       final jsonData = await importFile.readAsString();
//       final importData = jsonDecode(jsonData) as Map<String, dynamic>;
      
//       int customersImported = 0;
//       int documentsImported = 0;
//       int itemsImported = 0;
      
//       // Import customers
//       if (importData['customers'] != null) {
//         final existingCustomers = await loadCustomers();
//         final importCustomers = (importData['customers'] as List)
//             .map((c) => Customer.fromJson(c))
//             .toList();
        
//         // Merge with existing data (avoid duplicates by email)
//         final existingEmails = existingCustomers.map((c) => c.email).toSet();
//         final newCustomers = importCustomers
//             .where((c) => !existingEmails.contains(c.email))
//             .toList();
        
//         if (newCustomers.isNotEmpty) {
//           existingCustomers.addAll(newCustomers);
//           await saveCustomers(existingCustomers);
//           customersImported = newCustomers.length;
//         }
//       }
      
//       // Import documents
//       if (importData['documents'] != null) {
//         final existingDocuments = await loadDocuments();
//         final importDocuments = (importData['documents'] as List)
//             .map((d) => Document.fromJson(d))
//             .toList();
        
//         // Merge with existing data (avoid duplicates by number)
//         final existingNumbers = existingDocuments.map((d) => d.number).toSet();
//         final newDocuments = importDocuments
//             .where((d) => !existingNumbers.contains(d.number))
//             .toList();
        
//         if (newDocuments.isNotEmpty) {
//           existingDocuments.addAll(newDocuments);
//           await saveDocuments(existingDocuments);
//           documentsImported = newDocuments.length;
//         }
//       }
      
//       // Import items
//       if (importData['items'] != null) {
//         final existingItems = await loadItems();
//         final importItems = (importData['items'] as List)
//             .map((i) => Item.fromJson(i))
//             .toList();
        
//         // Merge with existing data (avoid duplicates by name)
//         final existingNames = existingItems.map((i) => i.name).toSet();
//         final newItems = importItems
//             .where((i) => !existingNames.contains(i.name))
//             .toList();
        
//         if (newItems.isNotEmpty) {
//           existingItems.addAll(newItems);
//           await saveItems(existingItems);
//           itemsImported = newItems.length;
//         }
//       }
      
//       return ImportResult(
//         success: true,
//         customersImported: customersImported,
//         documentsImported: documentsImported,
//         itemsImported: itemsImported,
//       );
      
//     } catch (e) {
//       return ImportResult(
//         success: false,
//         error: 'Failed to import data: $e',
//       );
//     }
//   }
// }

// // ==================== DATA MODELS ====================

// class BackupInfo {
//   final String fileName;
//   final String filePath;
//   final DateTime date;
//   final String appVersion;
//   final int fileSize;
//   final int customerCount;
//   final int documentCount;
//   final int itemCount;

//   BackupInfo({
//     required this.fileName,
//     required this.filePath,
//     required this.date,
//     required this.appVersion,
//     required this.fileSize,
//     required this.customerCount,
//     required this.documentCount,
//     required this.itemCount,
//   });

//   String get formattedSize {
//     if (fileSize < 1024) return '${fileSize}B';
//     if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
//     return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
//   }
// }

// class StorageStats {
//   final int totalSize;
//   final int userDataSize;
//   final int customersDataSize;
//   final int documentsDataSize;
//   final int itemsDataSize;
//   final int backupsSize;

//   StorageStats({
//     required this.totalSize,
//     required this.userDataSize,
//     required this.customersDataSize,
//     required this.documentsDataSize,
//     required this.itemsDataSize,
//     required this.backupsSize,
//   });

//   String _formatSize(int bytes) {
//     if (bytes < 1024) return '${bytes}B';
//     if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
//     return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
//   }

//   String get formattedTotalSize => _formatSize(totalSize);
//   String get formattedUserDataSize => _formatSize(userDataSize);
//   String get formattedCustomersDataSize => _formatSize(customersDataSize);
//   String get formattedDocumentsDataSize => _formatSize(documentsDataSize);
//   String get formattedItemsDataSize => _formatSize(itemsDataSize);
//   String get formattedBackupsSize => _formatSize(backupsSize);
// }

// class ImportResult {
//   final bool success;
//   final int customersImported;
//   final int documentsImported;
//   final int itemsImported;
//   final String? error;

//   ImportResult({
//     required this.success,
//     this.customersImported = 0,
//     this.documentsImported = 0,
//     this.itemsImported = 0,
//     this.error,
//   });

//   int get totalImported => customersImported + documentsImported + itemsImported;
// }




//2


// core/services/storage_service.dart - WEB VERSION USING EXISTING MOCK DATA
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../../data/models/customer.dart';
import '../../data/models/document.dart';
import '../../data/models/item.dart';
import '../constants/app_constants.dart';

class StorageService {
  static const String _userKey = 'quotation_maker_user';
  static const String _customersKey = 'quotation_maker_customers';
  static const String _documentsKey = 'quotation_maker_documents';
  static const String _itemsKey = 'quotation_maker_items';
  static const String _settingsKey = 'quotation_maker_settings';
  
  static bool _isInitialized = false;
  static html.Storage get _storage => html.window.localStorage;

  /// Initialize the storage service with mock data from API service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _isInitialized = true;
      debugPrint('✅ StorageService initialized (Web Storage)');
      
      // Initialize with the same mock data structure as your API service
      await _initializeWithMockData();
      
    } catch (e) {
      debugPrint('❌ StorageService initialization failed: $e');
      throw Exception('Failed to initialize storage service: $e');
    }
  }

  /// Initialize with exact mock data from your existing API service
  static Future<void> _initializeWithMockData() async {
    // Only initialize if no data exists
    if (_storage.containsKey(_userKey)) {
      debugPrint('📄 Using existing stored data');
      return;
    }
    
    debugPrint('📝 Initializing with mock data...');
    
    // Create demo user (same as in your MockApiService)
    final demoUser = User(
      id: _generateId(),
      email: 'demo@test.com',
      businessName: 'Demo Business Inc',
      settings: UserSettings(
        currency: AppConstants.defaultCurrency,
        currencySymbol: AppConstants.defaultCurrencySymbol,
        defaultTaxRate: AppConstants.defaultTaxRate,
        templateTheme: 'professional',
        businessInfo: BusinessInfo(
          name: 'Demo Business Inc',
          address: '123 Business Street',
          city: 'New York',
          state: 'NY',
          country: 'USA',
          zipCode: '10001',
          phone: '+1 (555) 123-4567',
          email: 'demo@test.com',
          website: 'www.demobusiness.com',
          taxId: 'TX123456789',
          registrationNumber: 'REG987654321',
        ),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
    await saveUser(demoUser);

    // Create sample customers (same as in your MockApiService)
    final customers = [
      Customer(
        id: _generateId(),
        name: 'Apple Inc.',
        email: 'contact@apple.com',
        phone: '+1 (408) 996-1010',
        address: '1 Apple Park Way',
        city: 'Cupertino',
        state: 'CA',
        country: 'USA',
        zipCode: '95014',
        notes: 'Premium technology client. Always pays on time.',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Customer(
        id: _generateId(),
        name: 'Microsoft Corporation',
        email: 'vendors@microsoft.com',
        phone: '+1 (425) 882-8080',
        address: '1 Microsoft Way',
        city: 'Redmond',
        state: 'WA',
        country: 'USA',
        zipCode: '98052',
        notes: 'Large enterprise client. Requires detailed invoicing.',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      Customer(
        id: _generateId(),
        name: 'Tesla Motors',
        email: 'accounting@tesla.com',
        phone: '+1 (512) 516-8177',
        address: '1 Tesla Road',
        city: 'Austin',
        state: 'TX',
        country: 'USA',
        zipCode: '78725',
        notes: 'Innovative automotive company. Fast decision making.',
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
    ];
    await saveCustomers(customers);

    // Create sample items (same as in your MockApiService)
    final items = [
      Item(
        id: _generateId(),
        name: 'Web Development',
        description: 'Custom website development with modern technologies',
        price: 5000.00,
        taxRate: 18.0,
        unit: 'project',
        category: 'Development',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Item(
        id: _generateId(),
        name: 'Mobile App Development',
        description: 'Native iOS and Android app development',
        price: 8000.00,
        taxRate: 18.0,
        unit: 'project',
        category: 'Development',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Item(
        id: _generateId(),
        name: 'UI/UX Design',
        description: 'User interface and experience design services',
        price: 150.00,
        taxRate: 18.0,
        unit: 'hour',
        category: 'Design',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
    await saveItems(items);

    // Create sample documents (same as in your MockApiService)
    final documents = [
      Document(
        id: _generateId(),
        type: 'Quote',
        number: 'QUO-001',
        customerId: customers[0].id,
        date: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        status: 'Draft',
        currency: 'USD',
        currencySymbol: '\$',
        items: [
          DocumentItem(
            id: _generateId(),
            documentId: '',
            itemId: items[0].id,
            name: items[0].name,
            description: items[0].description,
            quantity: 1,
            unitPrice: items[0].price,
            total: items[0].price,
            unit: items[0].unit,
          ),
        ],
        subtotal: 5000.00,
        taxAmount: 900.00,
        total: 5900.00,
        notes: 'Please review and confirm the requirements.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
    await saveDocuments(documents);
    
    debugPrint('✅ Mock data initialized successfully');
  }

  /// Generate unique ID (same as in MockApiService)
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (DateTime.now().microsecond % 1000).toString();
  }

  // ==================== USER DATA ====================

  static Future<void> saveUser(User user) async {
    try {
      final jsonData = jsonEncode(user.toJson());
      _storage[_userKey] = jsonData;
      debugPrint('User data saved');
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  static Future<User?> loadUser() async {
    try {
      final jsonData = _storage[_userKey];
      if (jsonData == null) return null;
      
      final userData = jsonDecode(jsonData) as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      debugPrint('Failed to load user data: $e');
      return null;
    }
  }

  static Future<void> deleteUser() async {
    try {
      _storage.remove(_userKey);
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  // ==================== CUSTOMERS DATA ====================

  static Future<void> saveCustomers(List<Customer> customers) async {
    try {
      final jsonData = jsonEncode(customers.map((c) => c.toJson()).toList());
      _storage[_customersKey] = jsonData;
      debugPrint('Customers data saved (${customers.length} customers)');
    } catch (e) {
      throw Exception('Failed to save customers data: $e');
    }
  }

  static Future<List<Customer>> loadCustomers() async {
    try {
      final jsonData = _storage[_customersKey];
      if (jsonData == null) return [];
      
      final customersData = jsonDecode(jsonData) as List;
      return customersData.map((c) => Customer.fromJson(c)).toList();
    } catch (e) {
      debugPrint('Failed to load customers data: $e');
      return [];
    }
  }

  // ==================== DOCUMENTS DATA ====================

  static Future<void> saveDocuments(List<Document> documents) async {
    try {
      final jsonData = jsonEncode(documents.map((d) => d.toJson()).toList());
      _storage[_documentsKey] = jsonData;
      debugPrint('Documents data saved (${documents.length} documents)');
    } catch (e) {
      throw Exception('Failed to save documents data: $e');
    }
  }

  static Future<List<Document>> loadDocuments() async {
    try {
      final jsonData = _storage[_documentsKey];
      if (jsonData == null) return [];
      
      final documentsData = jsonDecode(jsonData) as List;
      return documentsData.map((d) => Document.fromJson(d)).toList();
    } catch (e) {
      debugPrint('Failed to load documents data: $e');
      return [];
    }
  }

  // ==================== ITEMS DATA ====================

  static Future<void> saveItems(List<Item> items) async {
    try {
      final jsonData = jsonEncode(items.map((i) => i.toJson()).toList());
      _storage[_itemsKey] = jsonData;
      debugPrint('Items data saved (${items.length} items)');
    } catch (e) {
      throw Exception('Failed to save items data: $e');
    }
  }

  static Future<List<Item>> loadItems() async {
    try {
      final jsonData = _storage[_itemsKey];
      if (jsonData == null) return [];
      
      final itemsData = jsonDecode(jsonData) as List;
      return itemsData.map((i) => Item.fromJson(i)).toList();
    } catch (e) {
      debugPrint('Failed to load items data: $e');
      return [];
    }
  }

  // ==================== APP SETTINGS ====================

  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final jsonData = jsonEncode(settings);
      _storage[_settingsKey] = jsonData;
      debugPrint('App settings saved');
    } catch (e) {
      throw Exception('Failed to save app settings: $e');
    }
  }

  static Future<Map<String, dynamic>> loadAppSettings() async {
    try {
      final jsonData = _storage[_settingsKey];
      if (jsonData == null) return {};
      
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to load app settings: $e');
      return {};
    }
  }

  // ==================== BACKUP & RESTORE ====================

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
      backupData['app_version'] = '1.0.0';
      
      // Save to localStorage with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupKey = 'backup_$timestamp';
      _storage[backupKey] = jsonEncode(backupData);
      
      debugPrint('Backup created: $backupKey');
      return backupKey;
      
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  static Future<void> clearAllData() async {
    try {
      _storage.remove(_userKey);
      _storage.remove(_customersKey);
      _storage.remove(_documentsKey);
      _storage.remove(_itemsKey);
      _storage.remove(_settingsKey);
      debugPrint('All data cleared');
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  // ==================== EXPORT/IMPORT ====================

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
      
      // Create downloadable file for web
      final jsonString = jsonEncode(exportData);
      final blob = html.Blob([jsonString], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$fileName.json')
        ..click();
      
      html.Url.revokeObjectUrl(url);
      
      debugPrint('Data exported as: $fileName.json');
      return '$fileName.json';
      
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }
}

// Keep the same data model classes for compatibility
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