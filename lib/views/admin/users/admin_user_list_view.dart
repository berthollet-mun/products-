import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/controllers/user_controller.dart';
import 'package:product/models/user.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/theme/app_theme.dart';
import 'package:product/views/common/list_form_widgets.dart';
import 'package:product/views/common/role_guard.dart';

class AdminUserListView extends StatefulWidget {
  const AdminUserListView({super.key});

  @override
  State<AdminUserListView> createState() => _AdminUserListViewState();
}

class _AdminUserListViewState extends State<AdminUserListView> {
  final UserController controller = Get.find<UserController>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final horizontalPadding = (width * 0.045).clamp(14.0, 22.0);
    final gap = (Get.height * 0.015).clamp(10.0, 16.0);
    final maxWidth = math.min(width, 760.0);

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
          child: SafeArea(
            child: Obx(() {
              final users = _filteredUsers(controller.users);
              return RefreshIndicator(
                onRefresh: controller.loadAllUsers,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    gap,
                    horizontalPadding,
                    gap,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        children: [
                          PageActionHeader(
                            title: 'Utilisateurs',
                            buttonLabel: 'Ajouter',
                            onPressed: () async {
                              await Get.toNamed(AppRoutes.adminUserForm);
                              controller.loadAllUsers();
                            },
                          ),
                          SizedBox(height: gap),
                          SearchCardField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => _query = value.trim().toLowerCase());
                            },
                            hintText: 'Rechercher un utilisateur',
                          ),
                          SizedBox(height: gap),
                          if (controller.isLoading.value)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            )
                          else if (users.isEmpty)
                            _emptyState()
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return _userCard(user);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  List<User> _filteredUsers(List<User> all) {
    if (_query.isEmpty) {
      return all;
    }
    return all
        .where(
          (u) =>
              u.name.toLowerCase().contains(_query) ||
              u.email.toLowerCase().contains(_query),
        )
        .toList();
  }

  Widget _userCard(User user) {
    final isAdmin = user.role == 'admin';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all((Get.width * 0.04).clamp(12.0, 16.0)),
      decoration: AppTheme.glassCard(),
      child: Row(
        children: [
          Container(
            width: (Get.width * 0.12).clamp(44.0, 52.0),
            height: (Get.width * 0.12).clamp(44.0, 52.0),
            decoration: BoxDecoration(
              color: isAdmin ? const Color(0xFFDDEBFF) : const Color(0xFFDFF4F1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAdmin ? Icons.admin_panel_settings_rounded : Icons.badge_rounded,
              color: isAdmin ? AppTheme.adminPrimary : AppTheme.cashierPrimary,
            ),
          ),
          SizedBox(width: (Get.width * 0.03).clamp(8.0, 12.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    user.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: const Color(0xFF151D2F),
                    ),
                  ),
                ),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF707792),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? const Color(0xFFE9EEFF)
                        : const Color(0xFFE7F7F3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isAdmin ? 'ADMIN' : 'CAISSIER',
                    style: GoogleFonts.poppins(
                      color: isAdmin ? const Color(0xFF315DAE) : const Color(0xFF1E8D80),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () async {
                  await Get.toNamed(AppRoutes.adminUserForm, arguments: user);
                  controller.loadAllUsers();
                },
                icon: const Icon(Icons.edit_rounded, color: AppTheme.adminPrimary),
              ),
              IconButton(
                onPressed: () => _confirmDelete(user),
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC73838)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((Get.width * 0.06).clamp(18.0, 26.0)),
      decoration: AppTheme.glassCard(),
      child: Column(
        children: [
          const Icon(Icons.people_outline_rounded, size: 42, color: Color(0xFF8F97B0)),
          const SizedBox(height: 10),
          Text(
            'Aucun utilisateur trouve',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B738D),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(User user) async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer l\'utilisateur'),
        content: Text('Voulez-vous supprimer "${user.name}" ?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await controller.deleteUser(user.id);
    }
  }
}
