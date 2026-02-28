import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/responsive_helper.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Admin'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: isDesktop ? 120 : (isTablet ? 100 : 80),
                  color: Colors.blue,
                ),
                SizedBox(height: isDesktop ? 30 : (isTablet ? 25 : 20)),
                Text(
                  'Bienvenue Admin',
                  style: TextStyle(
                    fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isDesktop ? 40 : (isTablet ? 32 : 30)),
                // Menu Grid
                GridView.count(
                  crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
                  shrinkWrap: true,
                  padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
                  mainAxisSpacing: isDesktop ? 24 : (isTablet ? 20 : 16),
                  crossAxisSpacing: isDesktop ? 24 : (isTablet ? 20 : 16),
                  childAspectRatio: isDesktop ? 1.2 : (isTablet ? 1.0 : 1.1),
                  children: [
                    _buildMenuCard(
                      'Produits',
                      Icons.inventory_2,
                      Colors.blue,
                      () => Get.toNamed(AppRoutes.adminProductList),
                      context,
                    ),
                    _buildMenuCard(
                      'Entrées',
                      Icons.arrow_downward,
                      Colors.green,
                      () => Get.toNamed(AppRoutes.adminEntryForm),
                      context,
                    ),
                    _buildMenuCard(
                      'Sorties',
                      Icons.arrow_upward,
                      Colors.orange,
                      () => Get.toNamed(AppRoutes.adminOutputForm),
                      context,
                    ),
                    _buildMenuCard(
                      'Utilisateurs',
                      Icons.people,
                      Colors.purple,
                      () => Get.toNamed(AppRoutes.adminUserList),
                      context,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    BuildContext context,
  ) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Card(
      elevation: isDesktop ? 6 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isDesktop ? 64 : (isTablet ? 56 : 48),
              color: color,
            ),
            SizedBox(height: isDesktop ? 16 : (isTablet ? 14 : 12)),
            Text(
              title,
              style: TextStyle(
                fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
