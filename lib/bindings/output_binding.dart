import 'package:get/get.dart';
import '../controllers/output_controller.dart';
import '../services/output_service.dart';
import '../services/product_service.dart';

class OutputBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OutputService>(() => OutputService());
    Get.lazyPut<ProductService>(() => ProductService());
    Get.lazyPut<OutputController>(() => OutputController());
  }
}
