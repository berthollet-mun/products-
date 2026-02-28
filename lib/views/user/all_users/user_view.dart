import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/utils/responsive_helper.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/user.dart';
import './user_edit.dart';
import './user_form.dart';

class UserView extends StatelessWidget {
  UserView({super.key});

  final TextEditingController _searchController = TextEditingController();
  final Color _primaryColor = const Color(0xFF1E3A8A);

  void _showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildUserItem(User user, BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : (isTablet ? 20 : 16),
        vertical: isDesktop ? 12 : (isTablet ? 10 : 8),
      ),
      padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: isDesktop ? 60 : (isTablet ? 55 : 50),
          height: isDesktop ? 60 : (isTablet ? 55 : 50),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
              ),
            ),
          ),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
          ),
        ),
        subtitle: Text(
          '${user.email}\nRole: ${user.role}',
          style: TextStyle(
            color: Colors.white54,
            fontSize: isDesktop ? 15 : (isTablet ? 14 : 13),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // BOUTON ÉDITER
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white70),
              onPressed: () async {
                final userData = {
                  'id': user.id,
                  'email': user.email,
                  'name': user.name,
                  'role': user.role,
                };

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditUserForm(userData: userData),
                  ),
                );

                if (result != null && result['success'] == true) {
                  Get.find<UserController>().loadAllUsers();
                }
              },
            ),
            // BOUTON SUPPRIMER
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.redAccent,
              ),
              onPressed: () => _confirmDelete(user, context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(User user, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Supprimer ?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Voulez-vous supprimer ${user.name} ?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Get.find<UserController>().deleteUser(user.id);
        Get.find<UserController>().loadAllUsers();
        if (context.mounted) {
          _showMessage('${user.name} supprimé', context);
        }
      } catch (e) {
        if (context.mounted) {
          _showMessage('Erreur: $e', context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    userController.loadAllUsers();
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Utilisateurs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 22 : 20,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: Column(
            children: [
              // CHAMP DE RECHERCHE DESIGN
              Padding(
                padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un membre...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isDesktop ? 20 : 15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Obx(
                  () => userController.isLoading.value
                      ? Center(
                          child: CircularProgressIndicator(
                            color: _primaryColor,
                          ),
                        )
                      : userController.users.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: isDesktop ? 100 : (isTablet ? 80 : 64),
                                color: Colors.white24,
                              ),
                              SizedBox(height: isDesktop ? 24 : 16),
                              Text(
                                'Aucun utilisateur',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: isDesktop
                                      ? 20
                                      : (isTablet ? 18 : 16),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 16 : (isTablet ? 12 : 8),
                          ),
                          itemCount: userController.users.length,
                          itemBuilder: (context, index) => _buildUserItem(
                            userController.users[index],
                            context,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserForm()),
          );
          if (result != null && result['success'] == true) {
            Get.find<UserController>().loadAllUsers();
          }
        },
      ),
    );
  }
}
