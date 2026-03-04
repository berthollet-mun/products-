import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../services/product_service.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductService>()) {
      Get.lazyPut<ProductService>(() => ProductService(), fenix: true);
    }
    if (!Get.isRegistered<ProductController>()) {
      Get.lazyPut<ProductController>(
        () => ProductController(productService: Get.find<ProductService>()),
        fenix: true,
      );
    }
  }
}
