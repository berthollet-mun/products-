import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../services/user_service.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UserService>()) {
      Get.lazyPut<UserService>(() => UserService(), fenix: true);
    }
    if (!Get.isRegistered<UserController>()) {
      Get.lazyPut<UserController>(
        () => UserController(userService: Get.find<UserService>()),
        fenix: true,
      );
    }
  }
}
