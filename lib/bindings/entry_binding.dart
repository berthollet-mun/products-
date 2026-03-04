import 'package:get/get.dart';
import '../controllers/entry_controller.dart';
import '../services/entry_service.dart';
import '../services/product_service.dart';

class EntryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductService>()) {
      Get.lazyPut<ProductService>(() => ProductService(), fenix: true);
    }
    if (!Get.isRegistered<EntryService>()) {
      Get.lazyPut<EntryService>(
        () => EntryService(productService: Get.find<ProductService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<EntryController>()) {
      Get.lazyPut<EntryController>(
        () => EntryController(entryService: Get.find<EntryService>()),
        fenix: true,
      );
    }
  }
}
