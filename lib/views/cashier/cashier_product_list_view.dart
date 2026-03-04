import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../../utils/responsive_helper.dart';
import '../common/role_guard.dart';

class CashierProductListView extends StatelessWidget {
  const CashierProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return RoleGuard(
      requiredRole: 'caissier',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catalogue des Produits'),
          elevation: 0,
          backgroundColor: Colors.teal.shade700,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: isDesktop ? 120 : (isTablet ? 100 : 80),
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                  Text(
                    'Aucun produit disponible',
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
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return _buildProductCard(
                    product,
                    context,
                    isDesktop,
                    isTablet,
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProductCard(
    Product product,
    BuildContext context,
    bool isDesktop,
    bool isTablet,
  ) {
    final isLowStock = product.quantity <= product.stockMinimum;

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
            color: isLowStock ? Colors.red.shade100 : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
          ),
          child: Center(
            child: Text(
              product.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                fontWeight: FontWeight.bold,
                color: isLowStock ? Colors.red.shade700 : Colors.blue.shade700,
              ),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SKU: ${product.sku}',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
            Row(
              children: [
                Text(
                  'Stock: ${product.quantity}',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: isLowStock ? Colors.red : Colors.green,
                    fontWeight: isLowStock
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Prix: ${product.price}€',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 12,
            vertical: isDesktop ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: product.quantity > 0
                ? Colors.green.shade100
                : Colors.red.shade100,
            borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
          ),
          child: Text(
            product.quantity > 0 ? 'DISPONIBLE' : 'RUPTURE',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: product.quantity > 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
