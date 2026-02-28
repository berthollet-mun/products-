import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductController extends GetxController {
  final ProductService _service = ProductService();

  // État réactif
  RxList<Product> products = <Product>[].obs;
  RxBool isLoading = false.obs;
  RxString selectedProductId = ''.obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // CHARGER TOUS LES PRODUITS
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final loadedProducts = await _service.getAllProducts();
      products.assignAll(loadedProducts);
    } catch (e) {
      print("Erreur chargement: $e");
      Get.snackbar('Erreur', 'Erreur lors du chargement des produits');
    } finally {
      isLoading.value = false;
    }
  }

  // CRÉER UN NOUVEAU PRODUIT
  Future<bool> createNewProduct({
    required String name,
    required String sku,
    required double price,
    required int quantity,
    String? description,
  }) async {
    // Validation
    if (name.trim().isEmpty) {
      Get.snackbar('Erreur', 'Le nom est requis');
      return false;
    }
    if (sku.trim().isEmpty) {
      Get.snackbar('Erreur', 'Le SKU est obligatoire');
      return false;
    }
    if (price <= 0) {
      Get.snackbar('Erreur', 'Le prix doit être supérieur à zéro');
      return false;
    }
    if (quantity < 0) {
      Get.snackbar('Erreur', 'Le stock ne peut pas être négatif');
      return false;
    }

    try {
      isLoading.value = true;

      // Vérifier si SKU est unique
      final existingProduct = await _service.getProductBySku(sku.trim().toUpperCase());
      if (existingProduct != null) {
        Get.snackbar('Erreur', 'Ce code SKU est déjà utilisé');
        return false;
      }

      final newProduct = Product(
        id: const Uuid().v4(),
        name: name.trim(),
        sku: sku.trim().toUpperCase(),
        price: price,
        quantity: quantity,
        description: description ?? '',
      );

      final success = await _service.saveProduct(newProduct);
      
      if (success) {
        products.add(newProduct);
        Get.snackbar('Succès', 'Produit créé avec succès');
        return true;
      } else {
        Get.snackbar('Erreur', 'Erreur lors de la création du produit');
        return false;
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur système : $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // METTRE À JOUR UN PRODUIT
  Future<bool> updateProduct(Product updatedProduct) async {
    try {
      isLoading.value = true;

      final success = await _service.updateProduct(updatedProduct);
      
      if (success) {
        final index = products.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          products[index] = updatedProduct;
        }
        Get.snackbar('Succès', 'Produit mis à jour avec succès');
        return true;
      } else {
        Get.snackbar('Erreur', 'Erreur lors de la mise à jour');
        return false;
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // SUPPRIMER UN PRODUIT
  Future<bool> deleteProduct(String productId) async {
    try {
      isLoading.value = true;

      final success = await _service.deleteProduct(productId);
      
      if (success) {
        products.removeWhere((p) => p.id == productId);
        Get.snackbar('Succès', 'Produit supprimé avec succès');
        return true;
      } else {
        Get.snackbar('Erreur', 'Erreur lors de la suppression');
        return false;
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // METTRE À JOUR LE STOCK
  Future<bool> updateStock(String productId, int newQuantity) async {
    try {
      final success = await _service.updateStock(productId, newQuantity);
      
      if (success) {
        final index = products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          final product = products[index];
          products[index] = product.copyWith(quantity: newQuantity);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur updateStock: $e');
      return false;
    }
  }

  // OBTENIR UN PRODUIT PAR ID
  Product? getProductById(String productId) {
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  // RECHERCHER DES PRODUITS
  Future<void> searchProducts(String query) async {
    try {
      searchQuery.value = query;
      
      if (query.isEmpty) {
        await loadProducts();
        return;
      }
      
      isLoading.value = true;
      final results = await _service.searchProducts(query);
      products.assignAll(results);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la recherche');
    } finally {
      isLoading.value = false;
    }
  }

  // OBTENIR LES PRODUITS EN RUPTURE DE STOCK
  Future<List<Product>> getLowStockProducts() async {
    try {
      return await _service.getLowStockProducts();
    } catch (e) {
      print('Erreur getLowStockProducts: $e');
      return [];
    }
  }

  // VÉRIFIER LA DISPONIBILITÉ DU STOCK
  Future<bool> isStockAvailable(String productId, int requiredQuantity) async {
    try {
      return await _service.isStockAvailable(productId, requiredQuantity);
    } catch (e) {
      print('Erreur isStockAvailable: $e');
      return false;
    }
  }

  // OBTENIR LE STOCK D'UN PRODUIT
  Future<int?> getProductStock(String productId) async {
    try {
      return await _service.getProductStock(productId);
    } catch (e) {
      print('Erreur getProductStock: $e');
      return null;
    }
  }

  // SÉLECTIONNER UN PRODUIT
  void selectProduct(String productId) {
    selectedProductId.value = productId;
  }

  // OBTENIR LE NOMBRE TOTAL DE PRODUITS
  Future<int> getProductCount() async {
    try {
      return await _service.getProductCount();
    } catch (e) {
      print('Erreur getProductCount: $e');
      return 0;
    }
  }
}
