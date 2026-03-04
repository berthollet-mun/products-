import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/output_model.dart';
import 'product_controller.dart';
import '../services/output_service.dart';
import '../services/product_service.dart';

class OutputController extends GetxController {
  OutputController({
    OutputService? outputService,
    ProductService? productService,
  }) : _outputService = outputService ?? Get.find<OutputService>(),
       _productService = productService ?? Get.find<ProductService>();

  final OutputService _outputService;
  final ProductService _productService;

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

  Future<bool> createOutput({
    required String productId,
    required int quantity,
    required String userId,
  }) async {
    if (productId.isEmpty) {
      Get.snackbar('Erreur', 'Le produit est requis');
      return false;
    }
    if (quantity <= 0) {
      Get.snackbar('Erreur', 'La quantite doit etre superieure a 0');
      return false;
    }
    if (userId.isEmpty) {
      Get.snackbar('Erreur', 'L utilisateur est requis');
      return false;
    }

    try {
      isLoading.value = true;
      final outputId = const Uuid().v4();

      final success = await _outputService.createOutputWithStockDeduction(
        id: outputId,
        productId: productId,
        quantity: quantity,
        userId: userId,
      );

      if (!success) {
        Get.snackbar('Erreur', 'Stock insuffisant ou erreur de creation');
        return false;
      }

      await loadAllOutputs();
      await loadDailyStats();
      await _refreshProducts();
      Get.snackbar('Succes', 'Vente enregistree et stock mis a jour');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteOutput(String outputId) async {
    try {
      isLoading.value = true;
      final success = await _outputService.deleteOutputAndRestoreStock(outputId);

      if (!success) {
        Get.snackbar('Erreur', 'Erreur lors de la suppression');
        return false;
      }

      await loadAllOutputs();
      await loadDailyStats();
      await _refreshProducts();
      Get.snackbar('Succes', 'Vente annulee et stock restaure');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<List<Output>> getOutputsByProductId(String productId) async {
    try {
      return await _outputService.getOutputsByProductId(productId);
    } catch (e) {
      print('Erreur getOutputsByProductId: $e');
      return [];
    }
  }

  Future<List<Output>> getOutputsByUserId(String userId) async {
    try {
      return await _outputService.getOutputsByUserId(userId);
    } catch (e) {
      print('Erreur getOutputsByUserId: $e');
      return [];
    }
  }

  Future<List<Output>> getOutputsByUserIdAndDate(
    String userId,
    DateTime date,
  ) async {
    try {
      return await _outputService.getOutputsByUserIdAndDate(userId, date);
    } catch (e) {
      print('Erreur getOutputsByUserIdAndDate: $e');
      return [];
    }
  }

  Future<bool> isStockAvailable(String productId, int requiredQuantity) async {
    try {
      return await _productService.isStockAvailable(productId, requiredQuantity);
    } catch (e) {
      print('Erreur isStockAvailable: $e');
      return false;
    }
  }

  Future<int?> getProductStock(String productId) async {
    try {
      return await _productService.getProductStock(productId);
    } catch (e) {
      print('Erreur getProductStock: $e');
      return null;
    }
  }

  Future<void> _refreshProducts() async {
    if (Get.isRegistered<ProductController>()) {
      await Get.find<ProductController>().loadProducts();
    }
  }
}
