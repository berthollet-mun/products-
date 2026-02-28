import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/entry_model.dart';
import '../services/entry_service.dart';
import '../services/product_service.dart';

class EntryController extends GetxController {
  final EntryService _entryService = EntryService();
  final ProductService _productService = ProductService();

  // État réactif
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

  // CHARGER TOUTES LES ENTRÉES
  Future<void> loadAllEntries() async {
    try {
      isLoading.value = true;
      final loadedEntries = await _entryService.getAllEntries();
      entries.assignAll(loadedEntries);
    } catch (e) {
      print('Erreur loadAllEntries: $e');
      Get.snackbar('Erreur', 'Erreur lors du chargement des entrées');
    } finally {
      isLoading.value = false;
    }
  }

  // CRÉER UNE NOUVELLE ENTRÉE
  Future<bool> createEntry({
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

      final entryId = const Uuid().v4();

      // Créer l'entrée
      final success = await _entryService.createEntry(
        id: entryId,
        productId: productId,
        quantity: quantity,
        userId: userId,
      );

      if (success) {
        // Mettre à jour le stock du produit
        final currentProduct = await _productService.getProductById(productId);
        if (currentProduct != null) {
          final newQuantity = currentProduct.quantity + quantity;
          await _productService.updateStock(productId, newQuantity);
        }

        // Recharger les données
        await loadAllEntries();
        await loadDailyStats();
        
        Get.snackbar('Succès', 'Entrée créée et stock mis à jour');
        return true;
      }

      Get.snackbar('Erreur', 'Erreur lors de la création de l\'entrée');
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // SUPPRIMER UNE ENTRÉE
  Future<bool> deleteEntry(String entryId) async {
    try {
      isLoading.value = true;

      // Récupérer les détails de l'entrée avant suppression
      final entry = await _entryService.getEntryById(entryId);
      
      final success = await _entryService.deleteEntry(entryId);

      if (success && entry != null) {
        // Restaurer le stock du produit
        final currentProduct = await _productService.getProductById(entry.productId);
        if (currentProduct != null) {
          final newQuantity = (currentProduct.quantity - entry.quantity).clamp(0, double.infinity).toInt();
          await _productService.updateStock(entry.productId, newQuantity);
        }

        await loadAllEntries();
        await loadDailyStats();
        
        Get.snackbar('Succès', 'Entrée supprimée et stock préservé');
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
      final count = await _entryService.getTotalEntriesCountToday();
      final quantity = await _entryService.getTotalQuantityEnteredToday();
      
      totalEntriesCount.value = count;
      totalQuantityEntered.value = quantity;
    } catch (e) {
      print('Erreur loadDailyStats: $e');
    }
  }

  // RÉCUPÉRER LES ENTRÉES D'UN PRODUIT
  Future<List<Entry>> getEntriesByProductId(String productId) async {
    try {
      return await _entryService.getEntriesByProductId(productId);
    } catch (e) {
      print('Erreur getEntriesByProductId: $e');
      return [];
    }
  }

  // RÉCUPÉRER LES ENTRÉES D'UN UTILISATEUR
  Future<List<Entry>> getEntriesByUserId(String userId) async {
    try {
      return await _entryService.getEntriesByUserId(userId);
    } catch (e) {
      print('Erreur getEntriesByUserId: $e');
      return [];
    }
  }
}
