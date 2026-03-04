import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import '../models/output_model.dart';
import 'database_service.dart';
import 'product_service.dart';

class OutputService {
  OutputService({
    DatabaseService? databaseService,
    ProductService? productService,
  }) : _databaseService = databaseService ?? Get.find<DatabaseService>(),
       _productService = productService ?? Get.find<ProductService>();

  final DatabaseService _databaseService;
  final ProductService _productService;

  // CRÉER UNE NOUVELLE SORTIE
  Future<bool> createOutput({
    required String id,
    required String productId,
    required int quantity,
    required String userId,
  }) async {
    try {
      final db = _databaseService.database;
      await db.insert('stock_outputs', {
        'id': id,
        'product_id': productId,
        'quantity': quantity,
        'date': DateTime.now().toIso8601String(),
        'user_id': userId,
      }, conflictAlgorithm: ConflictAlgorithm.fail);
      return true;
    } catch (e) {
      print('Erreur createOutput: $e');
      return false;
    }
  }

  Future<bool> createOutputWithStockDeduction({
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
        final stockUpdated = await _productService.decrementStock(
          productId: productId,
          quantity: quantity,
          executor: txn,
        );

        if (!stockUpdated) {
          return false;
        }

        await txn.insert('stock_outputs', {
          'id': id,
          'product_id': productId,
          'quantity': quantity,
          'date': DateTime.now().toIso8601String(),
          'user_id': userId,
        }, conflictAlgorithm: ConflictAlgorithm.fail);

        return true;
      });
    } catch (e) {
      print('Erreur createOutputWithStockDeduction: $e');
      return false;
    }
  }

  // RÉCUPÉRER TOUTES LES SORTIES
  Future<List<Output>> getAllOutputs() async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_outputs',
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) => Output.fromMap(maps[i]));
    } catch (e) {
      print('Erreur getAllOutputs: $e');
      return [];
    }
  }

  // RÉCUPÉRER UNE SORTIE PAR ID
  Future<Output?> getOutputById(String outputId) async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_outputs',
        where: 'id = ?',
        whereArgs: [outputId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Output.fromMap(maps.first);
    } catch (e) {
      print('Erreur getOutputById: $e');
      return null;
    }
  }

  // RÉCUPÉRER LES SORTIES D'UN PRODUIT
  Future<List<Output>> getOutputsByProductId(String productId) async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_outputs',
        where: 'product_id = ?',
        whereArgs: [productId],
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) => Output.fromMap(maps[i]));
    } catch (e) {
      print('Erreur getOutputsByProductId: $e');
      return [];
    }
  }

  // RÉCUPÉRER LES SORTIES D'UN UTILISATEUR (CAISSIER)
  Future<List<Output>> getOutputsByUserId(String userId) async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_outputs',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) => Output.fromMap(maps[i]));
    } catch (e) {
      print('Erreur getOutputsByUserId: $e');
      return [];
    }
  }

  // SUPPRIMER UNE SORTIE
  Future<bool> deleteOutput(String outputId) async {
    try {
      final db = _databaseService.database;
      final rowsDeleted = await db.delete(
        'stock_outputs',
        where: 'id = ?',
        whereArgs: [outputId],
      );
      return rowsDeleted > 0;
    } catch (e) {
      print('Erreur deleteOutput: $e');
      return false;
    }
  }

  Future<bool> deleteOutputAndRestoreStock(String outputId) async {
    try {
      final db = _databaseService.database;
      return await db.transaction((txn) async {
        final maps = await txn.query(
          'stock_outputs',
          where: 'id = ?',
          whereArgs: [outputId],
          limit: 1,
        );

        if (maps.isEmpty) {
          return false;
        }

        final output = Output.fromMap(maps.first);
        final rowsDeleted = await txn.delete(
          'stock_outputs',
          where: 'id = ?',
          whereArgs: [outputId],
        );

        if (rowsDeleted <= 0) {
          return false;
        }

        final restored = await _productService.incrementStock(
          productId: output.productId,
          quantity: output.quantity,
          executor: txn,
        );

        return restored;
      });
    } catch (e) {
      print('Erreur deleteOutputAndRestoreStock: $e');
      return false;
    }
  }

  // OBTENIR TOTAL DES SORTIES DU JOUR
  Future<int> getTotalOutputsCountToday() async {
    try {
      final db = _databaseService.database;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final countMap = await db.rawQuery(
        'SELECT COUNT(*) as count FROM stock_outputs WHERE date >= ? AND date <= ?',
        [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );
      return Sqflite.firstIntValue(countMap) ?? 0;
    } catch (e) {
      print('Erreur getTotalOutputsCountToday: $e');
      return 0;
    }
  }

  // OBTENIR LA QUANTITÉ TOTALE SORTIE AUJOURD'HUI
  Future<int> getTotalQuantitySoldToday() async {
    try {
      final db = _databaseService.database;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final result = await db.rawQuery(
        'SELECT SUM(quantity) as total FROM stock_outputs WHERE date >= ? AND date <= ?',
        [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );

      if (result.isNotEmpty && result[0]['total'] != null) {
        return (result[0]['total'] as num).toInt();
      }
      return 0;
    } catch (e) {
      print('Erreur getTotalQuantitySoldToday: $e');
      return 0;
    }
  }

  // OBTENIR LES SORTIES D'UN UTILISATEUR POUR UNE DATE SPÉCIFIQUE
  Future<List<Output>> getOutputsByUserIdAndDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final db = _databaseService.database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final List<Map<String, dynamic>> maps = await db.query(
        'stock_outputs',
        where: 'user_id = ? AND date >= ? AND date <= ?',
        whereArgs: [
          userId,
          startOfDay.toIso8601String(),
          endOfDay.toIso8601String(),
        ],
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) => Output.fromMap(maps[i]));
    } catch (e) {
      print('Erreur getOutputsByUserIdAndDate: $e');
      return [];
    }
  }

  // OBTENIR LE MONTANT TOTAL VENDU AUJOURD'HUI (À FAIRE AVEC PRIX)
  // Cette méthode nécessiterait de joindre avec la table products pour obtenir les prix
  Future<double> getTotalSalesAmountToday() async {
    try {
      final db = _databaseService.database;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final result = await db.rawQuery(
        '''SELECT SUM(so.quantity * p.price) as total 
           FROM stock_outputs so 
           JOIN products p ON so.product_id = p.id 
           WHERE so.date >= ? AND so.date <= ?''',
        [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );

      if (result.isNotEmpty && result[0]['total'] != null) {
        return (result[0]['total'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('Erreur getTotalSalesAmountToday: $e');
      return 0.0;
    }
  }
}
