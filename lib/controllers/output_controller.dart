import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/output_model.dart';
import '../services/output_service.dart';
import '../services/product_service.dart';

class OutputController extends GetxController {
  final OutputService _outputService = OutputService();
  final ProductService _productService = ProductService();

  // État réactif
  RxList<Output> outputs = <Output>[].obs;
  RxBool isLoading = false.obs;
  RxInt totalOutputsCount = 0.obs;
  RxInt totalQuantitySold = 0.obs;
  RxDouble totalSalesAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllOutputs();
    loadDailyStats();
  }

  // CHARGER TOUTES LES SORTIES
  Future<void> loadAllOutputs() async {
    try {
      isLoading.value = true;
      final loadedOutputs = await _outputService.getAllOutputs();
      outputs.assignAll(loadedOutputs);
    } catch (e) {
      print('Erreur loadAllOutputs: $e');
      Get.snackbar('Erreur', 'Erreur lors du chargement des sorties');
    } finally {
      isLoading.value = false;
    }
  }

  // CRÉER UNE NOUVELLE SORTIE (VENTE)
  Future<bool> createOutput({
    required String productId,
    required int quantity,
    required String userId,
  }) async {
    // Validation
    if (productId.isEmpty) {
      Get.snackbar('Erreur', 'Le produit est requis');
      return false;
    }
    if (quantity <= 0) {
      Get.snackbar('Erreur', 'La quantité doit être supérieure à 0');
      return false;
    }
    if (userId.isEmpty) {
      Get.snackbar('Erreur', 'L\'utilisateur est requis');
      return false;
    }

    try {
      isLoading.value = true;

      // Vérifier que le stock est suffisant
      final isAvailable = await _productService.isStockAvailable(productId, quantity);
      if (!isAvailable) {
        Get.snackbar('Erreur', 'Stock insuffisant pour ce produit');
        return false;
      }

      final outputId = const Uuid().v4();

      // Créer la sortie
      final success = await _outputService.createOutput(
        id: outputId,
        productId: productId,
        quantity: quantity,
        userId: userId,
      );

      if (success) {
        // Mettre à jour le stock du produit
        final currentProduct = await _productService.getProductById(productId);
        if (currentProduct != null) {
          final newQuantity = currentProduct.quantity - quantity;
          await _productService.updateStock(productId, newQuantity);
        }

        // Recharger les données
        await loadAllOutputs();
        await loadDailyStats();
        
        Get.snackbar('Succès', 'Vente enregistrée et stock mis à jour');
        return true;
      }

      Get.snackbar('Erreur', 'Erreur lors de la création de la vente');
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // SUPPRIMER UNE SORTIE
  Future<bool> deleteOutput(String outputId) async {
    try {
      isLoading.value = true;

      // Récupérer les détails de la sortie avant suppression
      final output = await _outputService.getOutputById(outputId);
      
      final success = await _outputService.deleteOutput(outputId);

      if (success && output != null) {
        // Restaurer le stock du produit
        final currentProduct = await _productService.getProductById(output.productId);
        if (currentProduct != null) {
          final newQuantity = currentProduct.quantity + output.quantity;
          await _productService.updateStock(output.productId, newQuantity);
        }

        await loadAllOutputs();
        await loadDailyStats();
        
        Get.snackbar('Succès', 'Vente annulée et stock restauré');
        return true;
      }

      Get.snackbar('Erreur', 'Erreur lors de la suppression');
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // CHARGER LES STATISTIQUES DU JOUR
  Future<void> loadDailyStats() async {
    try {
      final count = await _outputService.getTotalOutputsCountToday();
      final quantity = await _outputService.getTotalQuantitySoldToday();
      final amount = await _outputService.getTotalSalesAmountToday();
      
      totalOutputsCount.value = count;
      totalQuantitySold.value = quantity;
      totalSalesAmount.value = amount;
    } catch (e) {
      print('Erreur loadDailyStats: $e');
    }
  }

  // RÉCUPÉRER LES SORTIES D'UN PRODUIT
  Future<List<Output>> getOutputsByProductId(String productId) async {
    try {
      return await _outputService.getOutputsByProductId(productId);
    } catch (e) {
      print('Erreur getOutputsByProductId: $e');
      return [];
    }
  }

  // RÉCUPÉRER LES SORTIES D'UN UTILISATEUR (CAISSIER)
  Future<List<Output>> getOutputsByUserId(String userId) async {
    try {
      return await _outputService.getOutputsByUserId(userId);
    } catch (e) {
      print('Erreur getOutputsByUserId: $e');
      return [];
    }
  }

  // RÉCUPÉRER LES SORTIES D'UN UTILISATEUR POUR UNE DATE SPÉCIFIQUE
  Future<List<Output>> getOutputsByUserIdAndDate(
      String userId, DateTime date) async {
    try {
      return await _outputService.getOutputsByUserIdAndDate(userId, date);
    } catch (e) {
      print('Erreur getOutputsByUserIdAndDate: $e');
      return [];
    }
  }

  // VÉRIFIER LA DISPONIBILITÉ DU STOCK
  Future<bool> isStockAvailable(String productId, int requiredQuantity) async {
    try {
      return await _productService.isStockAvailable(productId, requiredQuantity);
    } catch (e) {
      print('Erreur isStockAvailable: $e');
      return false;
    }
  }

  // OBTENIR LE STOCK D'UN PRODUIT
  Future<int?> getProductStock(String productId) async {
    try {
      return await _productService.getProductStock(productId);
    } catch (e) {
      print('Erreur getProductStock: $e');
      return null;
    }
  }
}
