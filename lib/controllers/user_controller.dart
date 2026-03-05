import 'package:get/get.dart';
import 'package:product/models/user.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/services/user_service.dart';

class UserController extends GetxController {
  UserController({UserService? userService})
    : _userService = userService ?? Get.find<UserService>();

  final UserService _userService;

  RxList<User> users = <User>[].obs;
  RxList<User> filteredUsers = <User>[].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;
  RxString selectedRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllUsers();
  }

  Future<void> loadAllUsers() async {
    try {
      isLoading.value = true;
      final loadedUsers = await _userService.getAllUsers();
      users.assignAll(loadedUsers);
      filteredUsers.assignAll(loadedUsers);
    } catch (_) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des utilisateurs');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addUser({
    required String id,
    required String email,
    required String password,
    required String role,
    required String name,
    String? profileImage,
  }) async {
    if (email.trim().isEmpty) {
      Get.snackbar('Erreur', 'L\'email est requis');
      return false;
    }
    if (password.trim().isEmpty) {
      Get.snackbar('Erreur', 'Le mot de passe est requis');
      return false;
    }
    if (name.trim().isEmpty) {
      Get.snackbar('Erreur', 'Le nom est requis');
      return false;
    }
    if (role != 'admin' && role != 'caissier') {
      Get.snackbar('Erreur', 'Le role doit etre "admin" ou "caissier"');
      return false;
    }

    try {
      isLoading.value = true;
      final emailTaken = await _userService.isEmailTaken(email);
      if (emailTaken) {
        Get.snackbar('Erreur', 'Cet email est deja utilise');
        return false;
      }

      final user = User(
        id: id,
        email: email.trim().toLowerCase(),
        password: password,
        role: role,
        name: name,
        profileImage: profileImage,
      );

      final success = await _userService.addUser(user);
      if (success) {
        users.add(user);
        filteredUsers.add(user);
        Get.snackbar('Succes', 'Utilisateur cree avec succes');
        if (Get.currentRoute == AppRoutes.adminUserForm &&
            (Get.key.currentState?.canPop() ?? false)) {
          Get.back(result: true);
        }
        return true;
      }

      Get.snackbar('Erreur', 'Erreur lors de la creation de l\'utilisateur');
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateUser({
    required String id,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      isLoading.value = true;
      final currentUser = _getUserById(id);
      if (currentUser == null) {
        Get.snackbar('Erreur', 'Utilisateur non trouve');
        return false;
      }

      final newEmail = updateData['email'] ?? currentUser.email;
      final newName = updateData['name'] ?? currentUser.name;
      final newRole = updateData['role'] ?? currentUser.role;
      final newPassword = updateData['password'] ?? currentUser.password;

      if (newEmail != currentUser.email) {
        final emailTaken = await _userService.isEmailTaken(newEmail);
        if (emailTaken) {
          Get.snackbar('Erreur', 'Cet email est deja utilise');
          return false;
        }
      }

      if (newRole != 'admin' && newRole != 'caissier') {
        Get.snackbar('Erreur', 'Le role doit etre "admin" ou "caissier"');
        return false;
      }

      final updatedUser = User(
        id: id,
        email: newEmail.trim().toLowerCase(),
        password: newPassword,
        role: newRole,
        name: newName,
        profileImage: currentUser.profileImage,
      );

      final success = await _userService.updateUser(updatedUser);
      if (success) {
        final index = users.indexWhere((u) => u.id == id);
        if (index != -1) {
          users[index] = updatedUser;
          final filteredIndex = filteredUsers.indexWhere((u) => u.id == id);
          if (filteredIndex != -1) {
            filteredUsers[filteredIndex] = updatedUser;
          }
        }
        Get.snackbar('Succes', 'Utilisateur mis a jour avec succes');
        if (Get.currentRoute == AppRoutes.adminUserForm &&
            (Get.key.currentState?.canPop() ?? false)) {
          Get.back(result: true);
        }
        return true;
      }

      Get.snackbar('Erreur', 'Erreur lors de la mise a jour');
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      final success = await _userService.deleteUser(userId);

      if (success) {
        users.removeWhere((u) => u.id == userId);
        filteredUsers.removeWhere((u) => u.id == userId);
        Get.snackbar('Succes', 'Utilisateur supprime avec succes');
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

  Future<void> searchUsers(String query) async {
    try {
      searchQuery.value = query;
      if (query.isEmpty) {
        filteredUsers.assignAll(users);
        return;
      }

      isLoading.value = true;
      final results = await _userService.searchUsers(query);
      filteredUsers.assignAll(results);
    } catch (_) {
      Get.snackbar('Erreur', 'Erreur lors de la recherche');
    } finally {
      isLoading.value = false;
    }
  }

  User? _getUserById(String id) {
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  void filterByRole(String role) {
    selectedRole.value = role;
    if (role.isEmpty) {
      filteredUsers.assignAll(users);
    } else {
      filteredUsers.assignAll(users.where((u) => u.role == role).toList());
    }
  }

  Future<List<User>> getAllCashiers() async {
    try {
      return await _userService.getAllCashiers();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isEmailAvailable(String email) async {
    try {
      return !(await _userService.isEmailTaken(email));
    } catch (_) {
      return false;
    }
  }

  Future<int> getUserCount() async {
    try {
      return await _userService.getUserCount();
    } catch (_) {
      return 0;
    }
  }
}
