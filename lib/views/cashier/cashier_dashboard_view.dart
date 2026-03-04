import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/controllers/auth_controller.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/utils/responsive_helper.dart';
import 'package:product/views/common/role_guard.dart';

class CashierDashboardView extends StatelessWidget {
  const CashierDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return RoleGuard(
      requiredRole: 'caissier',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tableau de bord Caissier'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: authController.logout,
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
                children: [
                  Icon(
                    Icons.point_of_sale,
                    size: isDesktop ? 120 : (isTablet ? 100 : 80),
                    color: Colors.teal,
                  ),
                  SizedBox(height: isDesktop ? 30 : (isTablet ? 25 : 20)),
                  Text(
                    'Bienvenue Caissier',
                    style: TextStyle(
                      fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 40 : (isTablet ? 32 : 30)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 48 : (isTablet ? 32 : 16),
                    ),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      padding: EdgeInsets.all(
                        isDesktop ? 24 : (isTablet ? 20 : 16),
                      ),
                      mainAxisSpacing: isDesktop ? 24 : (isTablet ? 20 : 16),
                      crossAxisSpacing: isDesktop ? 24 : (isTablet ? 20 : 16),
                      childAspectRatio: isDesktop
                          ? 1.2
                          : (isTablet ? 1.0 : 1.1),
                      children: [
                        _buildMenuCard(
                          'Produits',
                          Icons.inventory_2,
                          Colors.blue,
                          () => Get.toNamed(AppRoutes.cashierProductList),
                          context,
                        ),
                        _buildMenuCard(
                          'Vente',
                          Icons.shopping_cart,
                          Colors.orange,
                          () => Get.toNamed(AppRoutes.cashierOutputForm),
                          context,
                        ),
                        _buildMenuCard(
                          'Mes ventes',
                          Icons.receipt_long,
                          Colors.green,
                          () => Get.toNamed(AppRoutes.cashierOutputList),
                          context,
                        ),
                        _buildMenuCard(
                          'Historique',
                          Icons.history,
                          Colors.indigo,
                          () => Get.toNamed(AppRoutes.cashierHistory),
                          context,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
