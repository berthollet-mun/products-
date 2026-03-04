import 'package:get/get.dart';
import '../controllers/output_controller.dart';
import '../services/output_service.dart';
import '../services/product_service.dart';

class OutputBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductService>()) {
      Get.lazyPut<ProductService>(() => ProductService(), fenix: true);
    }
    if (!Get.isRegistered<OutputService>()) {
      Get.lazyPut<OutputService>(
        () => OutputService(productService: Get.find<ProductService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<OutputController>()) {
      Get.lazyPut<OutputController>(
        () => OutputController(
          outputService: Get.find<OutputService>(),
          productService: Get.find<ProductService>(),
        ),
        fenix: true,
      );
    }
  }
}
