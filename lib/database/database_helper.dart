import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  static const _dbVersion = 2;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'product.db');
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('admin', 'caissier')),
        name TEXT NOT NULL,
        profileImage TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        sku TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        price REAL NOT NULL CHECK (price >= 0),
        quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
        stock_minimum INTEGER NOT NULL DEFAULT 5 CHECK (stock_minimum >= 0),
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_entries (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL CHECK (quantity > 0),
        date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        user_id TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_outputs (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL CHECK (quantity > 0),
        date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        user_id TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        total REAL NOT NULL CHECK (total >= 0)
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id TEXT PRIMARY KEY,
        sale_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        qty INTEGER NOT NULL CHECK (qty > 0),
        price REAL NOT NULL CHECK (price >= 0),
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    await _createAdminUser(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfMissing(
        db: db,
        tableName: 'products',
        columnName: 'stock_minimum',
        sql:
            'ALTER TABLE products ADD COLUMN stock_minimum INTEGER NOT NULL DEFAULT 5',
      );

      await _addColumnIfMissing(
        db: db,
        tableName: 'products',
        columnName: 'created_at',
        sql:
            "ALTER TABLE products ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))",
      );

      await db.execute(
        "UPDATE products SET created_at = datetime('now', 'localtime') WHERE created_at IS NULL OR created_at = ''",
      );
    }
  }

  Future<void> _addColumnIfMissing({
    required Database db,
    required String tableName,
    required String columnName,
    required String sql,
  }) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final exists = columns.any((column) => column['name'] == columnName);
    if (!exists) {
      await db.execute(sql);
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> _createAdminUser(Database db) async {
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@local.com'],
    );
    if (existing.isNotEmpty) {
      return;
    }

    await db.insert('users', {
      'id': 'admin-id-001',
      'email': 'admin@local.com',
      'password': _hashPassword('@admin123'),
      'role': 'admin',
      'name': 'Administrateur',
      'profileImage': null,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> printAdminInfo() async {
    await database;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
