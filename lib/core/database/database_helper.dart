// lib/core/database/database_helper.dart
import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../../data/models/customer.dart';
import '../../data/models/document.dart';
import '../../data/models/item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, 'quotation_maker.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema updates
    debugPrint('Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < newVersion) {
      // Add migration logic here when needed
      await _createTables(db);
    }
  }

  Future<void> _createTables(Database db) async {
    // Users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        business_name TEXT NOT NULL,
        logo_path TEXT,
        settings TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        country TEXT,
        zip_code TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Items table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        tax_rate REAL DEFAULT 0.0,
        unit TEXT DEFAULT 'pcs',
        category TEXT,
        image_path TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Documents table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS documents (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        number TEXT UNIQUE NOT NULL,
        customer_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        due_date INTEGER,
        status TEXT NOT NULL,
        currency TEXT NOT NULL,
        currency_symbol TEXT NOT NULL,
        subtotal REAL NOT NULL,
        tax_amount REAL NOT NULL,
        discount_amount REAL DEFAULT 0.0,
        total REAL NOT NULL,
        notes TEXT,
        terms TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // Document items table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS document_items (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        item_id TEXT,
        name TEXT NOT NULL,
        description TEXT,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        discount REAL DEFAULT 0.0,
        tax_rate REAL DEFAULT 0.0,
        total REAL NOT NULL,
        unit TEXT DEFAULT 'pcs',
        FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // App settings table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX IF NOT EXISTS idx_customers_name ON customers (name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_customers_email ON customers (email)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_documents_customer_id ON documents (customer_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_documents_status ON documents (status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_documents_date ON documents (date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_items_name ON items (name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_items_category ON items (category)');
  }

  Future<void> _insertInitialData(Database db) async {
    // Insert default app settings
    final defaultSettings = {
      'app_version': '1.0.0',
      'database_version': '1',
      'first_launch': DateTime.now().millisecondsSinceEpoch.toString(),
      'dark_mode': 'false',
      'language': 'en',
      'currency': 'USD',
      'currency_symbol': '\$',
      'default_tax_rate': '18.0',
    };

    for (final entry in defaultSettings.entries) {
      await db.insert(
        'app_settings',
        {
          'key': entry.key,
          'value': entry.value,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Generic CRUD operations
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.rawQuery(sql, arguments);
  }

  Future<void> rawInsert(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.rawInsert(sql, arguments);
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Database maintenance
  Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
  }

  Future<int> getDatabaseSize() async {
    final path = join(await getDatabasesPath(), 'quotation_maker.db');
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // Backup and restore
  Future<String> backup() async {
    final path = join(await getDatabasesPath(), 'quotation_maker.db');
    final backupPath = join(await getDatabasesPath(), 'backup_${DateTime.now().millisecondsSinceEpoch}.db');
    
    final originalFile = File(path);
    if (await originalFile.exists()) {
      await originalFile.copy(backupPath);
      return backupPath;
    }
    throw Exception('Database file not found');
  }

  Future<void> restore(String backupPath) async {
    await close();
    
    final path = join(await getDatabasesPath(), 'quotation_maker.db');
    final backupFile = File(backupPath);
    
    if (await backupFile.exists()) {
      await backupFile.copy(path);
      _database = await _initDatabase();
    } else {
      throw Exception('Backup file not found');
    }
  }
}