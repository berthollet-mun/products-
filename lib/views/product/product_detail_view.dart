import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/utils/responsive_helper.dart';

import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import 'edit_product_form.dart';
import 'product_form.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final TextEditingController _searchController = TextEditingController();
  final Color _primaryColor = const Color(0xFF1E3A8A);

  @override
  void initState() {
    super.initState();
    // Charger les produits au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ProductController>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- WIDGET ITEM PRODUIT (STYLE USER ITEM) ---
  Widget _buildProductItem(Product product) {
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
          width: isDesktop ? 70 : (isTablet ? 60 : 55),
          height: isDesktop ? 70 : (isTablet ? 60 : 55),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(isDesktop ? 20 : 15),
          ),
          child: Center(
            child: Icon(
              Icons.inventory_2_rounded,
              color: _primaryColor,
              size: isDesktop ? 36 : (isTablet ? 32 : 28),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isDesktop ? 8 : 4),
            Text(
              'SKU: ${product.sku}',
              style: TextStyle(
                color: Colors.white54,
                fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
              ),
            ),
            Text(
              'Stock: ${product.quantity} | ${product.price} €',
              style: TextStyle(
                color: product.quantity < 5
                    ? Colors.orangeAccent
                    : Colors.greenAccent,
                fontWeight: FontWeight.w500,
                fontSize: isDesktop ? 15 : (isTablet ? 14 : 13),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // BOUTON ÉDITER (À implémenter si besoin)
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white70),
              onPressed: () async {
                // 1. Préparer les données sous forme de Map (exactement comme pour User)
                final productData = {
                  'id': product.id,
                  'name': product.name,
                  'sku': product.sku,
                  'price': product.price,
                  'quantity': product.quantity,
                  'description': product.description,
                };

                // 2. Naviguer vers le formulaire d'édition
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductForm(
                      productData: productData, // On ne passe QUE la Map
                    ),
                  ),
                );

                // 3. Recharger la liste si la modification a réussi
                if (result != null && result['success'] == true) {
                  Get.find<ProductController>().loadProducts();
                }
              },
            ),
            // BOUTON SUPPRIMER
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.redAccent,
              ),
              onPressed: () => _confirmDelete(product),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOGUE DE CONFIRMATION ---
  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Supprimer ?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Voulez-vous supprimer ${product.name} ?',
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
      final success = await Get.find<ProductController>().deleteProduct(
        product.id,
      );
      if (success) {
        _showMessage('Produit supprimé');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Obx(() {
      final controller = Get.find<ProductController>();

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text(
            'Stock Produits',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 24 : 20,
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
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          isDesktop ? 20 : 15,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: controller.isLoading.value
                      ? Center(
                          child: CircularProgressIndicator(
                            color: _primaryColor,
                          ),
                        )
                      : controller.products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: isDesktop ? 100 : (isTablet ? 80 : 64),
                                color: Colors.white24,
                              ),
                              SizedBox(height: isDesktop ? 24 : 16),
                              Text(
                                'Aucun produit en stock',
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
                          itemCount: controller.products.length,
                          itemBuilder: (context, index) =>
                              _buildProductItem(controller.products[index]),
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
              MaterialPageRoute(builder: (context) => const ProductForm()),
            );
            if (result != null && result['success'] == true) {
              Get.find<ProductController>().loadProducts();
            }
          },
        ),
      );
    });
  }
}
