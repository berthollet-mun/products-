import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/responsive_helper.dart';

class CashierDashboardView extends StatelessWidget {
  const CashierDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Caissier'),
        elevation: 0,
        backgroundColor: Colors.teal.shade700,
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
                // Menu Grid
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 48 : (isTablet ? 32 : 16),
                  ),
                  child: GridView.count(
                    crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 2,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(
                      isDesktop ? 24 : (isTablet ? 20 : 16),
                    ),
                    mainAxisSpacing: isDesktop ? 24 : (isTablet ? 20 : 16),
                    crossAxisSpacing: isDesktop ? 24 : (isTablet ? 20 : 16),
                    childAspectRatio: isDesktop ? 1.2 : (isTablet ? 1.0 : 1.1),
                    children: [
                      _buildMenuCard(
                        'Produits',
                        Icons.inventory_2,
                        Colors.blue,
                        () => Get.toNamed(AppRoutes.cashierProductList),
                        context,
                      ),
                      _buildMenuCard(
                        'Enregistrer Vente',
                        Icons.shopping_cart,
                        Colors.orange,
                        () => Get.toNamed(AppRoutes.cashierOutputForm),
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
