import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/product.dart';
import '../../../utils/responsive_helper.dart';
import 'admin_product_form_view.dart';

class AdminProductListView extends StatelessWidget {
  const AdminProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Produits'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
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
                  'Aucun produit',
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
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add),
        onPressed: () {
          Get.to(
            () => const AdminProductFormView(),
            transition: Transition.rightToLeft,
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    Product product,
    ProductController controller,
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
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
          ),
          child: Center(
            child: Text(
              product.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
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
            Text(
              'Stock: ${product.quantity} | Prix: ${product.price}€',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Modifier'),
              onTap: () {
                Get.to(
                  () => AdminProductFormView(product: product),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            PopupMenuItem(
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _confirmDelete(context, product, controller),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Product product,
    ProductController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Voulez-vous supprimer "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              controller.deleteProduct(product.id);
              Get.back();
              Get.snackbar('Succès', 'Produit supprimé');
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
