import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../services/entry_service.dart';
import '../services/output_service.dart';
import '../services/product_service.dart';

class DashboardBinding extends Bindings {
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
    if (!Get.isRegistered<OutputService>()) {
      Get.lazyPut<OutputService>(
        () => OutputService(productService: Get.find<ProductService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<DashboardController>()) {
      Get.lazyPut<DashboardController>(
        () => DashboardController(
          productService: Get.find<ProductService>(),
          entryService: Get.find<EntryService>(),
          outputService: Get.find<OutputService>(),
        ),
        fenix: true,
      );
    }
  }
}
