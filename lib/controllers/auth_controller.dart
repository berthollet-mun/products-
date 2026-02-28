import 'package:get/get.dart';
import 'package:product/models/user.dart';
import 'package:product/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  late User? currentUser;
  RxString currentRole = 'caissier'.obs;
  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  // Vérifier si un utilisateur est connecté au démarrage
  Future<void> checkAuthStatus() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      currentUser = await _authService.getCurrentUser();
      final role = await _authService.getCurrentUserRole();
      currentRole.value = role ?? 'caissier';
      isLoggedIn.value = true;
    }
  }

  // Connexion d'un utilisateur
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      final user = await _authService.login(email.trim(), password.trim());

      if (user != null) {
        currentUser = user;
        currentRole.value = user.role;
        isLoggedIn.value = true;

        // Redirection basée sur le rôle
        if (user.role == 'admin') {
          Get.offAllNamed('/admin-dashboard');
        } else {
          Get.offAllNamed('/cashier-dashboard');
        }

        return true;
      } else {
        Get.snackbar(
          'Erreur',
          'Email ou mot de passe incorrect',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
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

  // Déconnexion d'un utilisateur
  Future<void> logout() async {
    try {
      await _authService.logout();
      currentUser = null;
      currentRole.value = 'caissier';
      isLoggedIn.value = false;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Vérifier si l'utilisateur est administrateur
  bool get isAdmin => currentRole.value == 'admin';

  // Vérifier si l'utilisateur est caissier
  bool get isCashier => currentRole.value == 'caissier';
}

