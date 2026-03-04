import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import '../models/entry_model.dart';
import 'database_service.dart';
import 'product_service.dart';

class EntryService {
  EntryService({
    DatabaseService? databaseService,
    ProductService? productService,
  }) : _databaseService = databaseService ?? Get.find<DatabaseService>(),
       _productService = productService ?? Get.find<ProductService>();

  final DatabaseService _databaseService;
  final ProductService _productService;

  // CRÉER UNE NOUVELLE ENTRÉE
  Future<bool> createEntry({
    required String id,
    required String productId,
    required int quantity,
    required String userId,
  }) async {
    try {
      final db = _databaseService.database;
      await db.insert('stock_entries', {
        'id': id,
        'product_id': productId,
        'quantity': quantity,
        'date': DateTime.now().toIso8601String(),
        'user_id': userId,
      }, conflictAlgorithm: ConflictAlgorithm.fail);
      return true;
    } catch (e) {
      print('Erreur createEntry: $e');
      return false;
    }
  }

  Future<bool> createEntryWithStockUpdate({
    required String id,
    required String productId,
    required int quantity,
    required String userId,
  }) async {
    if (quantity <= 0) {
      return false;
    }

    try {
      final db = _databaseService.database;
      return await db.transaction((txn) async {
        final stockUpdated = await _productService.incrementStock(
          productId: productId,
          quantity: quantity,
          executor: txn,
        );

        if (!stockUpdated) {
          return false;
        }

        await txn.insert('stock_entries', {
          'id': id,
          'product_id': productId,
          'quantity': quantity,
          'date': DateTime.now().toIso8601String(),
          'user_id': userId,
        }, conflictAlgorithm: ConflictAlgorithm.fail);
        return true;
      });
    } catch (e) {
      print('Erreur createEntryWithStockUpdate: $e');
      return false;
    }
  }

  // RÉCUPÉRER TOUTES LES ENTRÉES
  Future<List<Entry>> getAllEntries() async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_entries',
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) => Entry.fromMap(maps[i]));
    } catch (e) {
      print('Erreur getAllEntries: $e');
      return [];
    }
  }

  // RÉCUPÉRER UNE ENTRÉE PAR ID
  Future<Entry?> getEntryById(String entryId) async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_entries',
        where: 'id = ?',
        whereArgs: [entryId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Entry.fromMap(maps.first);
    } catch (e) {
      print('Erreur getEntryById: $e');
      return null;
    }
  }

  // RÉCUPÉRER LES ENTRÉES D'UN PRODUIT
  Future<List<Entry>> getEntriesByProductId(String productId) async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_entries',
        where: 'product_id = ?',
        whereArgs: [productId],
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) => Entry.fromMap(maps[i]));
    } catch (e) {
      print('Erreur getEntriesByProductId: $e');
      return [];
    }
  }

  // RÉCUPÉRER LES ENTRÉES D'UN UTILISATEUR
  Future<List<Entry>> getEntriesByUserId(String userId) async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_entries',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) => Entry.fromMap(maps[i]));
    } catch (e) {
      print('Erreur getEntriesByUserId: $e');
      return [];
    }
  }

  // SUPPRIMER UNE ENTRÉE
  Future<bool> deleteEntry(String entryId) async {
    try {
      final db = _databaseService.database;
      final rowsDeleted = await db.delete(
        'stock_entries',
        where: 'id = ?',
        whereArgs: [entryId],
      );
      return rowsDeleted > 0;
    } catch (e) {
      print('Erreur deleteEntry: $e');
      return false;
    }
  }

  Future<bool> deleteEntryAndRestoreStock(String entryId) async {
    try {
      final db = _databaseService.database;
      return await db.transaction((txn) async {
        final maps = await txn.query(
          'stock_entries',
          where: 'id = ?',
          whereArgs: [entryId],
          limit: 1,
        );

        if (maps.isEmpty) {
          return false;
        }

        final entry = Entry.fromMap(maps.first);
        final stockUpdated = await _productService.decrementStock(
          productId: entry.productId,
          quantity: entry.quantity,
          executor: txn,
        );

        if (!stockUpdated) {
          return false;
        }

        final rowsDeleted = await txn.delete(
          'stock_entries',
          where: 'id = ?',
          whereArgs: [entryId],
        );

        return rowsDeleted > 0;
      });
    } catch (e) {
      print('Erreur deleteEntryAndRestoreStock: $e');
      return false;
    }
  }

  // OBTENIR TOTAL DES ENTRÉES DU JOUR
  Future<int> getTotalEntriesCountToday() async {
    try {
      final db = _databaseService.database;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final countMap = await db.rawQuery(
        'SELECT COUNT(*) as count FROM stock_entries WHERE date >= ? AND date <= ?',
        [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );
      return Sqflite.firstIntValue(countMap) ?? 0;
    } catch (e) {
      print('Erreur getTotalEntriesCountToday: $e');
      return 0;
    }
  }

  // OBTENIR LA QUANTITÉ TOTALE ENTRÉE AUJOURD'HUI
  Future<int> getTotalQuantityEnteredToday() async {
    try {
      final db = _databaseService.database;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final result = await db.rawQuery(
        'SELECT SUM(quantity) as total FROM stock_entries WHERE date >= ? AND date <= ?',
        [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );

      if (result.isNotEmpty && result[0]['total'] != null) {
        return (result[0]['total'] as num).toInt();
      }
      return 0;
    } catch (e) {
      print('Erreur getTotalQuantityEnteredToday: $e');
      return 0;
    }
  }
}
