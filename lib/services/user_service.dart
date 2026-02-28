import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:product/models/user.dart';
import 'database_service.dart';

class UserService {
  late final DatabaseService _databaseService;

  UserService() {
    _databaseService = Get.find<DatabaseService>();
  }

  // Hachage du mot de passe
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Ajouter un nouvel utilisateur
  Future<bool> addUser(User user) async {
    try {
      final db = _databaseService.database;
      // Hasher le mot de passe avant de sauvegarder
      final hashedPassword = _hashPassword(user.password);
      final userMap = user.toMap();
      userMap['password'] = hashedPassword;

      await db.insert('users', userMap);
      print('Utilisateur ${user.name} ajouté avec succès');
      return true;
    } catch (e) {
      print('Erreur addUser: $e');
      return false;
    }
  }

  // Mettre à jour un utilisateur existant
  Future<bool> updateUser(User user) async {
    try {
      final db = _databaseService.database;
      // Hasher le mot de passe si nécessaire
      final hashedPassword = _hashPassword(user.password);
      final userMap = user.toMap();
      userMap['password'] = hashedPassword;

      final rowsChanged = await db.update(
        'users',
        userMap,
        where: 'id = ?',
        whereArgs: [user.id],
      );
      print('Utilisateur ${user.name} mis à jour');
      return rowsChanged > 0;
    } catch (e) {
      print('Erreur updateUser: $e');
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
      print('Utilisateur $userId supprimé');
      return rowsDeleted > 0;
    } catch (e) {
      print('Erreur deleteUser: $e');
      return false;
    }
  }

  // Récupérer tous les utilisateurs
  Future<List<User>> getAllUsers() async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query('users');
      return List.generate(maps.length, (i) => User.fromMap(maps[i]));
    } catch (e) {
      print('Erreur getAllUsers: $e');
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
      print('Erreur getUserById: $e');
      return null;
    }
  }

  // Vérifier si un email est déjà utilisé
  Future<bool> isEmailTaken(String email) async {
    try {
      final db = _databaseService.database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim().toLowerCase()],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Erreur isEmailTaken: $e');
      return false;
    }
  }

  // Rechercher des utilisateurs par mot-clé
  Future<List<User>> searchUsers(String query) async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'name LIKE ? OR email LIKE ? OR role LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
      );
      return maps.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      print('Erreur searchUsers: $e');
      return [];
    }
  }

  // Récupérer tous les caissiers
  Future<List<User>> getAllCashiers() async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: ['caissier'],
      );
      return List.generate(maps.length, (i) => User.fromMap(maps[i]));
    } catch (e) {
      print('Erreur getAllCashiers: $e');
      return [];
    }
  }

  // Obtenir le nombre total d'utilisateurs
  Future<int> getUserCount() async {
    try {
      final db = _databaseService.database;
      final countMap = await db.rawQuery('SELECT COUNT(*) as count FROM users');
      return int.parse(countMap[0]['count'].toString());
    } catch (e) {
      print('Erreur getUserCount: $e');
      return 0;
    }
  }
}
