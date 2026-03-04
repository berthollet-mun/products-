import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import 'database_service.dart';

class ProductService {
  ProductService({DatabaseService? databaseService})
    : _databaseService = databaseService ?? Get.find<DatabaseService>();

  final DatabaseService _databaseService;

  // CHARGER TOUS LES PRODUITS
  Future<List<Product>> getAllProducts() async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        orderBy: 'name ASC',
      );
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    } catch (e) {
      print("Erreur getAllProducts: $e");
      return [];
    }
  }

  // OBTENIR UN PRODUIT PAR ID
  Future<Product?> getProductById(String productId) async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Product.fromMap(maps.first);
    } catch (e) {
      print("Erreur getProductById: $e");
      return null;
    }
  }

  // OBTENIR UN PRODUIT PAR SKU
  Future<Product?> getProductBySku(String sku) async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'sku = ?',
        whereArgs: [sku],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Product.fromMap(maps.first);
    } catch (e) {
      print("Erreur getProductBySku: $e");
      return null;
    }
  }

  // INSERTION D'UN NOUVEAU PRODUIT
  Future<bool> saveProduct(Product product) async {
    try {
      final db = _databaseService.database;
      await db.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true;
    } catch (e) {
      print("Erreur saveProduct: $e");
      return false;
    }
  }

  // MISE À JOUR D'UN PRODUIT
  Future<bool> updateProduct(Product product) async {
    try {
      final db = _databaseService.database;
      final rowsChanged = await db.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      return rowsChanged > 0;
    } catch (e) {
      print("Erreur updateProduct: $e");
      return false;
    }
  }

  // SUPPRESSION D'UN PRODUIT
  Future<bool> deleteProduct(String productId) async {
    try {
      final db = _databaseService.database;
      final rowsDeleted = await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
      );
      return rowsDeleted > 0;
    } catch (e) {
      print("Erreur deleteProduct: $e");
      return false;
    }
  }

  // METTRE À JOUR LE STOCK
  Future<bool> updateStock(String productId, int newQuantity) async {
    if (newQuantity < 0) {
      return false;
    }

    try {
      final db = _databaseService.database;
      final rowsChanged = await db.update(
        'products',
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [productId],
      );
      return rowsChanged > 0;
    } catch (e) {
      print("Erreur updateStock: $e");
      return false;
    }
  }

  Future<bool> incrementStock({
    required String productId,
    required int quantity,
    DatabaseExecutor? executor,
  }) async {
    if (quantity <= 0) {
      return false;
    }

    try {
      final db = executor ?? _databaseService.database;
      final rowsChanged = await db.rawUpdate(
        'UPDATE products SET quantity = quantity + ? WHERE id = ?',
        [quantity, productId],
      );
      return rowsChanged > 0;
    } catch (e) {
      print("Erreur incrementStock: $e");
      return false;
    }
  }

  Future<bool> decrementStock({
    required String productId,
    required int quantity,
    DatabaseExecutor? executor,
  }) async {
    if (quantity <= 0) {
      return false;
    }

    try {
      final db = executor ?? _databaseService.database;
      final rowsChanged = await db.rawUpdate(
        'UPDATE products SET quantity = quantity - ? WHERE id = ? AND quantity >= ?',
        [quantity, productId, quantity],
      );
      return rowsChanged > 0;
    } catch (e) {
      print("Erreur decrementStock: $e");
      return false;
    }
  }

  // OBTENIR LE STOCK D'UN PRODUIT
  Future<int?> getProductStock(String productId) async {
    try {
      final product = await getProductById(productId);
      return product?.quantity;
    } catch (e) {
      print("Erreur getProductStock: $e");
      return null;
    }
  }

  // VÉRIFIER SI LE STOCK EST SUFFISANT
  Future<bool> isStockAvailable(String productId, int requiredQuantity) async {
    try {
      final stock = await getProductStock(productId);
      return stock != null && stock >= requiredQuantity;
    } catch (e) {
      print("Erreur isStockAvailable: $e");
      return false;
    }
  }

  // RECHERCHER DES PRODUITS
  Future<List<Product>> searchProducts(String query) async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'name LIKE ? OR sku LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    } catch (e) {
      print("Erreur searchProducts: $e");
      return [];
    }
  }

  // OBTENIR LES PRODUITS EN RUPTURE DE STOCK
  Future<List<Product>> getLowStockProducts() async {
    try {
      final db = _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'quantity <= stock_minimum',
        orderBy: 'quantity ASC',
      );
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    } catch (e) {
      print("Erreur getLowStockProducts: $e");
      return [];
    }
  }

  // OBTENIR LE NOMBRE TOTAL DE PRODUITS
  Future<int> getProductCount() async {
    try {
      final db = _databaseService.database;
      final countMap = await db.rawQuery(
        'SELECT COUNT(*) as count FROM products',
      );
      return Sqflite.firstIntValue(countMap) ?? 0;
    } catch (e) {
      print("Erreur getProductCount: $e");
      return 0;
    }
  }
}
