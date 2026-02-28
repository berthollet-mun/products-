import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Getter pour recupere l'intance de la base de donnee

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  // initialisation de l'instance de la base de donnee
  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'product.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Méthode pour hacher un mot de passe
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convertir en bytes
    var digest = sha256.convert(bytes); // Hasher avec SHA-256
    return digest.toString(); // Retourner le hash en string
  }

  // creation de la base de donnee
  Future<void> _onCreate(Database db, int version) async {
    // Table des utilisateurs
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

    // Table des produits
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        sku TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        price REAL NOT NULL CHECK (price >= 0),
        quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
        description TEXT
      )
    ''');

    // Table des entrées de stock
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

    // Table des sorties de stock (ventes)
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

    // Table des ventes (entête) - optionnel pour compatibilité
    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        total REAL NOT NULL CHECK (total >= 0)
      )
    ''');

    // Table des détails de vente (lignes de vente)
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

    print("Base de données et tables créées avec succès!");

    await _createAdminUser(db);

    print("Base créée et admin ajouté !");
  }

  // Méthode pour créer l'utilisateur admin
  Future<void> _createAdminUser(Database db) async {
    try {
      // Vérifier d'abord si l'admin existe déjà
      List<Map<String, dynamic>> existingAdmin = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: ['admin@local.com'],
      );

      // Si l'admin n'existe pas, le créer
      if (existingAdmin.isEmpty) {
        String hashedPassword = _hashPassword(
          '@admin123',
        ); // Hash du mot de passe

        await db.insert(
          'users',
          {
            'id': 'admin-id-001', // id obligatoire
            'email': 'admin@local.com', // Connexion via email
            'password': hashedPassword, // Mot de passe hashé
            'role': 'admin', // Rôle pour accès total
            'name': 'Administrateur', // Nom affiché
            'profileImage': null, // Optionnel
          },
          conflictAlgorithm: ConflictAlgorithm.ignore, // Ignorer si doublon
        );

        print("Utilisateur admin créé avec succès!");
      } else {
        print("L'utilisateur admin existe déjà");
      }
    } catch (e) {
      print("Erreur lors de la création de l'admin: $e");
    }
  }

  Future<void> printAdminInfo() async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@local.com'],
    );
    print("Admin en base: $result");

    // Afficher le hash du mot de passe pour vérifier
    final hashedPassword = sha256.convert(utf8.encode('@admin123')).toString();
    print("Hash de '@admin123': $hashedPassword");
  }

  // Fermeture de la connexion a la base de donnee
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database!;
    }
  }
}
