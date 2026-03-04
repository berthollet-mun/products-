import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/user.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/responsive_helper.dart';
import '../../common/role_guard.dart';

class AdminUserListView extends StatelessWidget {
  const AdminUserListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion des Utilisateurs'),
          elevation: 0,
          backgroundColor: Colors.purple.shade700,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: isDesktop ? 120 : (isTablet ? 100 : 80),
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                  Text(
                    'Aucun utilisateur',
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.getMaxContentWidth(context),
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 16 : 8)),
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return _buildUserCard(
                    user,
                    controller,
                    context,
                    isDesktop,
                    isTablet,
                  );
                },
              ),
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple.shade700,
          child: const Icon(Icons.add),
          onPressed: () async {
            // Use named route to ensure binding is applied
            await Get.toNamed(AppRoutes.adminUserForm);
            // Refresh list when returning
            controller.loadAllUsers();
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(
    User user,
    UserController controller,
    BuildContext context,
    bool isDesktop,
    bool isTablet,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : (isTablet ? 12 : 8),
        vertical: isDesktop ? 8 : (isTablet ? 6 : 4),
      ),
      elevation: isDesktop ? 4 : 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : (isTablet ? 20 : 16),
          vertical: isDesktop ? 12 : (isTablet ? 8 : 4),
        ),
        leading: Container(
          width: isDesktop ? 70 : (isTablet ? 60 : 50),
          height: isDesktop ? 70 : (isTablet ? 60 : 50),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                user.role == 'admin'
                    ? Colors.purple.shade600
                    : Colors.green.shade600,
                user.role == 'admin'
                    ? Colors.purple.shade400
                    : Colors.green.shade400,
              ],
            ),
            borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
          ),
          child: Center(
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: TextStyle(fontSize: isDesktop ? 16 : 14)),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 12 : 8,
                vertical: isDesktop ? 4 : 2,
              ),
              decoration: BoxDecoration(
                color: user.role == 'admin'
                    ? Colors.purple.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  color: user.role == 'admin'
                      ? Colors.purple.shade700
                      : Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Modifier'),
              onTap: () async {
                // Use named route to ensure binding is applied
                await Get.toNamed(AppRoutes.adminUserForm, arguments: user);
                // Refresh list when returning
                controller.loadAllUsers();
              },
            ),
            PopupMenuItem(
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _confirmDelete(context, user, controller),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    User user,
    UserController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer l\'utilisateur'),
        content: Text('Voulez-vous supprimer "${user.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              controller.deleteUser(user.id);
              Get.back();
              Get.snackbar('Succès', 'Utilisateur supprimé');
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
