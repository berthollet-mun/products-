import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/product.dart';
import '../routes/app_routes.dart';
import '../services/product_service.dart';

class ProductController extends GetxController {
  ProductController({ProductService? productService})
    : _service = productService ?? Get.find<ProductService>();

  final ProductService _service;

  RxList<Product> products = <Product>[].obs;
  RxBool isLoading = false.obs;
  RxString selectedProductId = ''.obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final loadedProducts = await _service.getAllProducts();
      products.assignAll(loadedProducts);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des produits');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createNewProduct({
    required String name,
    required String sku,
    required double price,
    required int quantity,
    int stockMinimum = 5,
    String? description,
  }) async {
    if (name.trim().isEmpty) {
      Get.snackbar('Erreur', 'Le nom est requis');
      return false;
    }
    if (sku.trim().isEmpty) {
      Get.snackbar('Erreur', 'Le SKU est obligatoire');
      return false;
    }
    if (price <= 0) {
      Get.snackbar('Erreur', 'Le prix doit etre superieur a zero');
      return false;
    }
    if (quantity < 0) {
      Get.snackbar('Erreur', 'Le stock ne peut pas etre negatif');
      return false;
    }

    try {
      isLoading.value = true;
      final existingProduct = await _service.getProductBySku(
        sku.trim().toUpperCase(),
      );
      if (existingProduct != null) {
        Get.snackbar('Erreur', 'Ce code SKU est deja utilise');
        return false;
      }

      final newProduct = Product(
        id: const Uuid().v4(),
        name: name.trim(),
        sku: sku.trim().toUpperCase(),
        price: price,
        quantity: quantity,
        stockMinimum: stockMinimum,
        createdAt: DateTime.now().toIso8601String(),
        description: description ?? '',
      );

      final success = await _service.saveProduct(newProduct);
      if (success) {
        products.add(newProduct);
        Get.snackbar('Succes', 'Produit cree avec succes');
        if (Get.currentRoute == AppRoutes.adminProductForm &&
            (Get.key.currentState?.canPop() ?? false)) {
          Get.back(result: true);
        }
        return true;
      }

      Get.snackbar('Erreur', 'Erreur lors de la creation du produit');
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur systeme: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProduct(Product updatedProduct) async {
    try {
      isLoading.value = true;
      final success = await _service.updateProduct(updatedProduct);

      if (success) {
        final index = products.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          products[index] = updatedProduct;
        }
        Get.snackbar('Succes', 'Produit mis a jour avec succes');
        if (Get.currentRoute == AppRoutes.adminProductForm &&
            (Get.key.currentState?.canPop() ?? false)) {
          Get.back(result: true);
        }
        return true;
      }

      Get.snackbar('Erreur', 'Erreur lors de la mise a jour');
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise a jour: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      final success = await _service.deleteProduct(productId);

      if (success) {
        products.removeWhere((p) => p.id == productId);
        Get.snackbar('Succes', 'Produit supprime avec succes');
        return true;
      }

      Get.snackbar('Erreur', 'Erreur lors de la suppression');
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

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
      return false;
    }
  }

  Product? getProductById(String productId) {
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

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
    } catch (_) {
      Get.snackbar('Erreur', 'Erreur lors de la recherche');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Product>> getLowStockProducts() async {
    try {
      return await _service.getLowStockProducts();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isStockAvailable(String productId, int requiredQuantity) async {
    try {
      return await _service.isStockAvailable(productId, requiredQuantity);
    } catch (_) {
      return false;
    }
  }

  Future<int?> getProductStock(String productId) async {
    try {
      return await _service.getProductStock(productId);
    } catch (_) {
      return null;
    }
  }

  void selectProduct(String productId) {
    selectedProductId.value = productId;
  }

  Future<int> getProductCount() async {
    try {
      return await _service.getProductCount();
    } catch (_) {
      return 0;
    }
  }
}
