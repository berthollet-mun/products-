import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/entry_model.dart';
import 'product_controller.dart';
import '../services/entry_service.dart';

class EntryController extends GetxController {
  EntryController({EntryService? entryService})
    : _entryService = entryService ?? Get.find<EntryService>();

  final EntryService _entryService;

  RxList<Entry> entries = <Entry>[].obs;
  RxBool isLoading = false.obs;
  RxInt totalEntriesCount = 0.obs;
  RxInt totalQuantityEntered = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllEntries();
    loadDailyStats();
  }

  Future<void> loadAllEntries() async {
    try {
      isLoading.value = true;
      final loadedEntries = await _entryService.getAllEntries();
      entries.assignAll(loadedEntries);
    } catch (e) {
      print('Erreur loadAllEntries: $e');
      Get.snackbar('Erreur', 'Erreur lors du chargement des entrees');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createEntry({
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
      final entryId = const Uuid().v4();

      final success = await _entryService.createEntryWithStockUpdate(
        id: entryId,
        productId: productId,
        quantity: quantity,
        userId: userId,
      );

      if (!success) {
        Get.snackbar('Erreur', 'Erreur lors de la creation de l entree');
        return false;
      }

      await loadAllEntries();
      await loadDailyStats();
      await _refreshProducts();
      Get.snackbar('Succes', 'Entree creee et stock mis a jour');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteEntry(String entryId) async {
    try {
      isLoading.value = true;

      final success = await _entryService.deleteEntryAndRestoreStock(entryId);
      if (!success) {
        Get.snackbar(
          'Erreur',
          'Suppression impossible (stock actuel insuffisant ou entree absente)',
        );
        return false;
      }

      await loadAllEntries();
      await loadDailyStats();
      await _refreshProducts();
      Get.snackbar('Succes', 'Entree supprimee et stock preserve');
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
      final count = await _entryService.getTotalEntriesCountToday();
      final quantity = await _entryService.getTotalQuantityEnteredToday();
      totalEntriesCount.value = count;
      totalQuantityEntered.value = quantity;
    } catch (e) {
      print('Erreur loadDailyStats: $e');
    }
  }

  Future<List<Entry>> getEntriesByProductId(String productId) async {
    try {
      return await _entryService.getEntriesByProductId(productId);
    } catch (e) {
      print('Erreur getEntriesByProductId: $e');
      return [];
    }
  }

  Future<List<Entry>> getEntriesByUserId(String userId) async {
    try {
      return await _entryService.getEntriesByUserId(userId);
    } catch (e) {
      print('Erreur getEntriesByUserId: $e');
      return [];
    }
  }

  Future<void> _refreshProducts() async {
    if (Get.isRegistered<ProductController>()) {
      await Get.find<ProductController>().loadProducts();
    }
  }
}
