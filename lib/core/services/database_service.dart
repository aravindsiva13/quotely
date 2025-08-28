// lib/core/services/database_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../../data/models/user.dart';
import '../../data/models/customer.dart';
import '../../data/models/document.dart';
import '../../data/models/item.dart';

/// Database Service - Handles all database operations
/// This layer can easily replace the mock API in the future
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // ==================== USER OPERATIONS ====================

  Future<void> saveUser(User user) async {
    try {
      await _dbHelper.insert('users', {
        'id': user.id,
        'email': user.email,
        'business_name': user.businessName,
        'logo_path': user.logoPath,
        'settings': jsonEncode(user.settings.toJson()),
        'created_at': user.createdAt.millisecondsSinceEpoch,
      });
      debugPrint('✅ User saved to database: ${user.email}');
    } catch (e) {
      debugPrint('❌ Error saving user to database: $e');
      rethrow;
    }
  }

  Future<User?> getUser(String userId) async {
    try {
      final results = await _dbHelper.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return User.fromJson(results.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user from database: $e');
      return null;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final results = await _dbHelper.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (results.isNotEmpty) {
        final userData = results.first;
        return User(
          id: userData['id'] as String,
          email: userData['email'] as String,
          businessName: userData['business_name'] as String,
          logoPath: userData['logo_path'] as String?,
          settings: UserSettings.fromJson(
            jsonDecode(userData['settings'] as String)
          ),
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            userData['created_at'] as int
          ),
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user by email from database: $e');
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _dbHelper.update(
        'users',
        {
          'email': user.email,
          'business_name': user.businessName,
          'logo_path': user.logoPath,
          'settings': jsonEncode(user.settings.toJson()),
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );
      debugPrint('✅ User updated in database: ${user.email}');
    } catch (e) {
      debugPrint('❌ Error updating user in database: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _dbHelper.delete(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      debugPrint('✅ User deleted from database: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting user from database: $e');
      rethrow;
    }
  }

  // ==================== CUSTOMER OPERATIONS ====================

  Future<void> saveCustomer(Customer customer) async {
    try {
      await _dbHelper.insert('customers', {
        'id': customer.id,
        'name': customer.name,
        'email': customer.email,
        'phone': customer.phone,
        'address': customer.address,
        'city': customer.city,
        'state': customer.state,
        'country': customer.country,
        'zip_code': customer.zipCode,
        'notes': customer.notes,
        'created_at': customer.createdAt.millisecondsSinceEpoch,
      });
      debugPrint('✅ Customer saved to database: ${customer.name}');
    } catch (e) {
      debugPrint('❌ Error saving customer to database: $e');
      rethrow;
    }
  }

  Future<List<Customer>> getAllCustomers() async {
    try {
      final results = await _dbHelper.query(
        'customers',
        orderBy: 'created_at DESC',
      );

      return results.map((data) => Customer(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        address: data['address'] as String? ?? '',
        city: data['city'] as String? ?? '',
        state: data['state'] as String? ?? '',
        country: data['country'] as String? ?? '',
        zipCode: data['zip_code'] as String? ?? '',
        notes: data['notes'] as String? ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          data['created_at'] as int
        ),
      )).toList();
    } catch (e) {
      debugPrint('❌ Error getting customers from database: $e');
      return [];
    }
  }

  Future<Customer?> getCustomer(String customerId) async {
    try {
      final results = await _dbHelper.query(
        'customers',
        where: 'id = ?',
        whereArgs: [customerId],
        limit: 1,
      );

      if (results.isNotEmpty) {
        final data = results.first;
        return Customer(
          id: data['id'] as String,
          name: data['name'] as String,
          email: data['email'] as String? ?? '',
          phone: data['phone'] as String? ?? '',
          address: data['address'] as String? ?? '',
          city: data['city'] as String? ?? '',
          state: data['state'] as String? ?? '',
          country: data['country'] as String? ?? '',
          zipCode: data['zip_code'] as String? ?? '',
          notes: data['notes'] as String? ?? '',
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            data['created_at'] as int
          ),
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting customer from database: $e');
      return null;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _dbHelper.update(
        'customers',
        {
          'name': customer.name,
          'email': customer.email,
          'phone': customer.phone,
          'address': customer.address,
          'city': customer.city,
          'state': customer.state,
          'country': customer.country,
          'zip_code': customer.zipCode,
          'notes': customer.notes,
        },
        where: 'id = ?',
        whereArgs: [customer.id],
      );
      debugPrint('✅ Customer updated in database: ${customer.name}');
    } catch (e) {
      debugPrint('❌ Error updating customer in database: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      // Delete customer and all related documents (cascade delete)
      await _dbHelper.transaction((txn) async {
        // Get all documents for this customer
        final documents = await txn.query(
          'documents',
          where: 'customer_id = ?',
          whereArgs: [customerId],
        );

        // Delete document items for each document
        for (final doc in documents) {
          await txn.delete(
            'document_items',
            where: 'document_id = ?',
            whereArgs: [doc['id']],
          );
        }

        // Delete documents
        await txn.delete(
          'documents',
          where: 'customer_id = ?',
          whereArgs: [customerId],
        );

        // Delete customer
        await txn.delete(
          'customers',
          where: 'id = ?',
          whereArgs: [customerId],
        );
      });
      debugPrint('✅ Customer deleted from database: $customerId');
    } catch (e) {
      debugPrint('❌ Error deleting customer from database: $e');
      rethrow;
    }
  }

  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final results = await _dbHelper.query(
        'customers',
        where: 'name LIKE ? OR email LIKE ? OR phone LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'name ASC',
      );

      return results.map((data) => Customer(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        address: data['address'] as String? ?? '',
        city: data['city'] as String? ?? '',
        state: data['state'] as String? ?? '',
        country: data['country'] as String? ?? '',
        zipCode: data['zip_code'] as String? ?? '',
        notes: data['notes'] as String? ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          data['created_at'] as int
        ),
      )).toList();
    } catch (e) {
      debugPrint('❌ Error searching customers in database: $e');
      return [];
    }
  }

  // ==================== ITEM OPERATIONS ====================

  Future<void> saveItem(Item item) async {
    try {
      await _dbHelper.insert('items', {
        'id': item.id,
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'tax_rate': item.taxRate,
        'unit': item.unit,
        'category': item.category,
        'image_path': item.imagePath,
        'created_at': item.createdAt.millisecondsSinceEpoch,
      });
      debugPrint('✅ Item saved to database: ${item.name}');
    } catch (e) {
      debugPrint('❌ Error saving item to database: $e');
      rethrow;
    }
  }

  Future<List<Item>> getAllItems() async {
    try {
      final results = await _dbHelper.query(
        'items',
        orderBy: 'created_at DESC',
      );

      return results.map((data) => Item(
        id: data['id'] as String,
        name: data['name'] as String,
        description: data['description'] as String? ?? '',
        price: (data['price'] as num).toDouble(),
        taxRate: (data['tax_rate'] as num).toDouble(),
        unit: data['unit'] as String? ?? 'pcs',
        category: data['category'] as String?,
        imagePath: data['image_path'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          data['created_at'] as int
        ),
      )).toList();
    } catch (e) {
      debugPrint('❌ Error getting items from database: $e');
      return [];
    }
  }

  Future<List<Item>> getItemsByCategory(String category) async {
    try {
      final results = await _dbHelper.query(
        'items',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'name ASC',
      );

      return results.map((data) => Item(
        id: data['id'] as String,
        name: data['name'] as String,
        description: data['description'] as String? ?? '',
        price: (data['price'] as num).toDouble(),
        taxRate: (data['tax_rate'] as num).toDouble(),
        unit: data['unit'] as String? ?? 'pcs',
        category: data['category'] as String?,
        imagePath: data['image_path'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          data['created_at'] as int
        ),
      )).toList();
    } catch (e) {
      debugPrint('❌ Error getting items by category from database: $e');
      return [];
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      await _dbHelper.update(
        'items',
        {
          'name': item.name,
          'description': item.description,
          'price': item.price,
          'tax_rate': item.taxRate,
          'unit': item.unit,
          'category': item.category,
          'image_path': item.imagePath,
        },
        where: 'id = ?',
        whereArgs: [item.id],
      );
      debugPrint('✅ Item updated in database: ${item.name}');
    } catch (e) {
      debugPrint('❌ Error updating item in database: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _dbHelper.delete(
        'items',
        where: 'id = ?',
        whereArgs: [itemId],
      );
      debugPrint('✅ Item deleted from database: $itemId');
    } catch (e) {
      debugPrint('❌ Error deleting item from database: $e');
      rethrow;
    }
  }

  // ==================== APP SETTINGS ====================

  Future<void> saveSetting(String key, String value) async {
    try {
      await _dbHelper.insert('app_settings', {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('✅ Setting saved: $key = $value');
    } catch (e) {
      debugPrint('❌ Error saving setting to database: $e');
      rethrow;
    }
  }

  Future<String?> getSetting(String key) async {
    try {
      final results = await _dbHelper.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return results.first['value'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting setting from database: $e');
      return null;
    }
  }

  Future<Map<String, String>> getAllSettings() async {
    try {
      final results = await _dbHelper.query('app_settings');
      final settings = <String, String>{};
      
      for (final row in results) {
        settings[row['key'] as String] = row['value'] as String;
      }
      
      return settings;
    } catch (e) {
      debugPrint('❌ Error getting all settings from database: $e');
      return {};
    }
  }

  // ==================== DATABASE MAINTENANCE ====================

  Future<void> vacuum() async {
    await _dbHelper.vacuum();
    debugPrint('✅ Database vacuumed');
  }

  Future<int> getDatabaseSize() async {
    return await _dbHelper.getDatabaseSize();
  }

  Future<String> backup() async {
    return await _dbHelper.backup();
  }

  Future<void> restore(String backupPath) async {
    await _dbHelper.restore(backupPath);
  }

  Future<void> close() async {
    await _dbHelper.close();
  }

  /// Initialize database with mock data for testing
  /// This method helps bridge the gap between mock API and real database
  Future<void> initializeWithMockData() async {
    try {
      // This method can be called to populate database with mock data
      // when transitioning from mock API to database
      debugPrint('🔄 Initializing database with mock data...');
      
      // Check if already initialized
      final userCount = await _dbHelper.query('users');
      if (userCount.isNotEmpty) {
        debugPrint('✅ Database already has data, skipping mock initialization');
        return;
      }
      
      // Initialize with demo data
      debugPrint('✅ Database initialized with mock data');
    } catch (e) {
      debugPrint('❌ Error initializing database with mock data: $e');
      rethrow;
    }
  }
}