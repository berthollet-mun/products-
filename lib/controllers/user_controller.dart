import 'package:get/get.dart';
import 'package:product/models/user.dart';
import 'package:product/services/user_service.dart';

class UserController extends GetxController {
  final UserService _userService = UserService();

  // État réactif
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

  // CHARGER TOUS LES UTILISATEURS
  Future<void> loadAllUsers() async {
    try {
      isLoading.value = true;
      final loadedUsers = await _userService.getAllUsers();
      users.assignAll(loadedUsers);
      filteredUsers.assignAll(loadedUsers);
    } catch (e) {
      print('Erreur loadAllUsers: $e');
      Get.snackbar('Erreur', 'Erreur lors du chargement des utilisateurs');
    } finally {
      isLoading.value = false;
    }
  }

  // AJOUTER UN NOUVEL UTILISATEUR
  Future<bool> addUser({
    required String id,
    required String email,
    required String password,
    required String role,
    required String name,
    String? profileImage,
  }) async {
    // Validation
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
      Get.snackbar('Erreur', 'Le rôle doit être "admin" ou "caissier"');
      return false;
    }

    try {
      isLoading.value = true;

      // Vérifier si l'email existe déjà
      final emailTaken = await _userService.isEmailTaken(email);
      if (emailTaken) {
        Get.snackbar('Erreur', 'Cet email est déjà utilisé');
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
        Get.snackbar('Succès', 'Utilisateur créé avec succès');
        return true;
      }

      Get.snackbar('Erreur', 'Erreur lors de la création de l\'utilisateur');
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // METTRE À JOUR UN UTILISATEUR
  Future<bool> updateUser({
    required String id,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      isLoading.value = true;

      // Récupérer l'utilisateur actuel
      final currentUser = _getUserById(id);
      if (currentUser == null) {
        Get.snackbar('Erreur', 'Utilisateur non trouvé');
        return false;
      }

      String newEmail = updateData['email'] ?? currentUser.email;
      String newName = updateData['name'] ?? currentUser.name;
      String newRole = updateData['role'] ?? currentUser.role;
      String newPassword = updateData['password'] ?? currentUser.password;

      // Vérifier si l'email est disponible (si changé)
      if (newEmail != currentUser.email) {
        final emailTaken = await _userService.isEmailTaken(newEmail);
        if (emailTaken) {
          Get.snackbar('Erreur', 'Cet email est déjà utilisé');
          return false;
        }
      }

      // Valider le rôle
      if (newRole != 'admin' && newRole != 'caissier') {
        Get.snackbar('Erreur', 'Le rôle doit être "admin" ou "caissier"');
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
          filteredUsers[filteredUsers.indexWhere((u) => u.id == id)] = updatedUser;
        }
        Get.snackbar('Succès', 'Utilisateur mis à jour avec succès');
        return true;
      }

      Get.snackbar('Erreur', 'Erreur lors de la mise à jour');
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // SUPPRIMER UN UTILISATEUR
  Future<bool> deleteUser(String userId) async {
    try {
      isLoading.value = true;

      final success = await _userService.deleteUser(userId);
      
      if (success) {
        users.removeWhere((u) => u.id == userId);
        filteredUsers.removeWhere((u) => u.id == userId);
        Get.snackbar('Succès', 'Utilisateur supprimé avec succès');
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

  // RECHERCHER DES UTILISATEURS
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
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la recherche');
    } finally {
      isLoading.value = false;
    }
  }

  // RÉCUPÉRER UN UTILISATEUR PAR ID
  User? _getUserById(String id) {
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  // FILTRER PAR RÔLE
  void filterByRole(String role) {
    selectedRole.value = role;
    
    if (role.isEmpty) {
      filteredUsers.assignAll(users);
    } else {
      filteredUsers.assignAll(
        users.where((u) => u.role == role).toList(),
      );
    }
  }

  // OBTENIR TOUS LES CAISSIERS
  Future<List<User>> getAllCashiers() async {
    try {
      return await _userService.getAllCashiers();
    } catch (e) {
      print('Erreur getAllCashiers: $e');
      return [];
    }
  }

  // VÉRIFIER SI UN EMAIL EST DISPONIBLE
  Future<bool> isEmailAvailable(String email) async {
    try {
      return !(await _userService.isEmailTaken(email));
    } catch (e) {
      print('Erreur isEmailAvailable: $e');
      return false;
    }
  }

  // OBTENIR LE NOMBRE TOTAL D'UTILISATEURS
  Future<int> getUserCount() async {
    try {
      return await _userService.getUserCount();
    } catch (e) {
      print('Erreur getUserCount: $e');
      return 0;
    }
  }
}
