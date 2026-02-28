import 'package:get/get.dart';
import '../controllers/entry_controller.dart';
import '../services/entry_service.dart';
import '../services/product_service.dart';

class EntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EntryService>(() => EntryService());
    Get.lazyPut<ProductService>(() => ProductService());
    Get.lazyPut<EntryController>(() => EntryController());
  }
}
