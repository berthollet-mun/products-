import 'package:get/get.dart';
import 'package:product/models/user.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/services/auth_service.dart';

class AuthController extends GetxController {
  AuthController({AuthService? authService})
    : _authService = authService ?? Get.find<AuthService>();

  final AuthService _authService;

  final Rxn<User> currentUser = Rxn<User>();
  final RxString currentRole = 'caissier'.obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;

      final loggedIn = await _authService.isLoggedIn();
      if (!loggedIn) {
        isLoggedIn.value = false;
        currentUser.value = null;
        currentRole.value = 'caissier';
        return;
      }

      currentUser.value = await _authService.getCurrentUser();
      currentRole.value =
          (await _authService.getCurrentUserRole()) ?? 'caissier';
      isLoggedIn.value = currentUser.value != null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      final user = await _authService.login(email.trim(), password.trim());
      if (user == null) {
        Get.snackbar(
          'Erreur',
          'Email ou mot de passe incorrect',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      currentUser.value = user;
      currentRole.value = user.role;
      isLoggedIn.value = true;

      final route = user.role == 'admin'
          ? AppRoutes.adminDashboard
          : AppRoutes.cashierDashboard;
      Get.offAllNamed(route);
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur login: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      currentUser.value = null;
      currentRole.value = 'caissier';
      isLoggedIn.value = false;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool get isAdmin => currentRole.value == 'admin';
  bool get isCashier => currentRole.value == 'caissier';
}
