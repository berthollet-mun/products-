import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:product/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class AuthService {
  AuthService({DatabaseService? databaseService})
    : _databaseService = databaseService ?? Get.find<DatabaseService>();

  final DatabaseService _databaseService;

  // Hachage du mot de passe
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Connexion d'un utilisateur [Login utilisateur]
  Future<User?> login(String email, String password) async {
    try {
      final db = _databaseService.database;
      final hashedPassword = _hashPassword(password);

      print("Email reçu: $email");
      print("Password haché: $hashedPassword");

      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
        limit: 1,
      );

      if (result.isEmpty) {
        print("Aucun utilisateur trouvé");
        return null;
      }

      final user = User.fromMap(result.first);
      print("Utilisateur trouvé: $user");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', user.id);
      await prefs.setString('current_user_role', user.role);

      return user;
    } catch (e) {
      print("Erreur login: $e");
      return null;
    }
  }

  // Déconnexion d'un utilisateur
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    await prefs.remove('current_user_role');
  }

  // Récupérer l'utilisateur actuel
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');

      if (userId == null) return null;

      final db = _databaseService.database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (result.isEmpty) return null;

      return User.fromMap(result.first);
    } catch (e) {
      print("Erreur getCurrentUser: $e");
      return null;
    }
  }

  // Récupérer le rôle actuel depuis SharedPreferences
  Future<String?> getCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user_role');
  }

  // Vérifier si un utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('current_user_id');
  }

  // Ajouter un nouvel utilisateur (Admin uniquement)
  Future<bool> createUser({
    required String id,
    required String email,
    required String password,
    required String role,
    required String name,
    String? profileImage,
  }) async {
    try {
      final db = _databaseService.database;
      final hashedPassword = _hashPassword(password);

      await db.insert('users', {
        'id': id,
        'email': email,
        'password': hashedPassword,
        'role': role,
        'name': name,
        'profileImage': profileImage,
      });

      return true;
    } catch (e) {
      print("Erreur createUser: $e");
      return false;
    }
  }

  // Modifier un utilisateur
  Future<bool> updateUser(User user) async {
    try {
      final db = _databaseService.database;
      final hashedPassword = _hashPassword(user.password);

      final rowsChanged = await db.update(
        'users',
        {...user.toMap(), 'password': hashedPassword},
        where: 'id = ?',
        whereArgs: [user.id],
      );

      return rowsChanged > 0;
    } catch (e) {
      print("Erreur updateUser: $e");
      return false;
    }
  }

  // Supprimer un utilisateur
  Future<bool> deleteUser(String userId) async {
    try {
      final db = _databaseService.database;

      final rowsDeleted = await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      return rowsDeleted > 0;
    } catch (e) {
      print("Erreur deleteUser: $e");
      return false;
    }
  }

  // Récupérer tous les utilisateurs
  Future<List<User>> getAllUsers() async {
    try {
      final db = _databaseService.database;
      final result = await db.query('users');
      return result.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      print("Erreur getAllUsers: $e");
      return [];
    }
  }

  // Récupérer un utilisateur par ID
  Future<User?> getUserById(String userId) async {
    try {
      final db = _databaseService.database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return User.fromMap(result.first);
    } catch (e) {
      print("Erreur getUserById: $e");
      return null;
    }
  }
}
