import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/models/product.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/theme/app_theme.dart';
import 'package:product/views/common/list_form_widgets.dart';
import 'package:product/views/common/role_guard.dart';

class AdminProductListView extends StatefulWidget {
  const AdminProductListView({super.key});

  @override
  State<AdminProductListView> createState() => _AdminProductListViewState();
}

class _AdminProductListViewState extends State<AdminProductListView> {
  final ProductController controller = Get.find<ProductController>();
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
              final products = _filteredProducts(controller.products);
              return RefreshIndicator(
                onRefresh: controller.loadProducts,
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
                          SearchCardField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => _query = value.trim().toLowerCase());
                            },
                            hintText: 'Rechercher un produit',
                          ),
                          SizedBox(height: gap),
                            PageActionHeader(
                            title: 'Produits',
                            buttonLabel: 'Ajouter produits',
                            onPressed: () => Get.toNamed(AppRoutes.adminProductForm),
                          ),
                          SizedBox(height: gap),
                          if (controller.isLoading.value)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            )
                          else if (products.isEmpty)
                            _emptyState()
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return _productCard(product);
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

  List<Product> _filteredProducts(List<Product> all) {
    if (_query.isEmpty) {
      return all;
    }
    return all
        .where(
          (p) =>
              p.name.toLowerCase().contains(_query) ||
              p.sku.toLowerCase().contains(_query),
        )
        .toList();
  }

  Widget _productCard(Product product) {
    final isLowStock = product.quantity <= product.stockMinimum;
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(product),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEC),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC73838)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all((Get.width * 0.04).clamp(12.0, 16.0)),
        decoration: AppTheme.glassCard(),
        child: Row(
          children: [
            Container(
              width: (Get.width * 0.12).clamp(44.0, 52.0),
              height: (Get.width * 0.12).clamp(44.0, 52.0),
              decoration: BoxDecoration(
                color: const Color(0xFFDDEBFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: AppTheme.adminPrimary,
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
                      product.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: const Color(0xFF151D2F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${product.sku}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF707792),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge(
                        'Stock ${product.quantity}',
                        isLowStock
                            ? const Color(0xFFFFE9E7)
                            : const Color(0xFFE7F7F3),
                        isLowStock
                            ? const Color(0xFFC94A40)
                            : const Color(0xFF1E8D80),
                      ),
                      _badge(
                        '${product.price.toStringAsFixed(2)} EUR',
                        const Color(0xFFE9EEFF),
                        const Color(0xFF315DAE),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  Get.toNamed(AppRoutes.adminProductForm, arguments: product),
              icon: const Icon(Icons.edit_rounded, color: AppTheme.adminPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String value, Color background, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
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
          const Icon(Icons.inventory_2_outlined, size: 42, color: Color(0xFF8F97B0)),
          const SizedBox(height: 10),
          Text(
            'Aucun produit trouve',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B738D),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(Product product) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Voulez-vous supprimer "${product.name}" ?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result == true) {
      await controller.deleteProduct(product.id);
      return true;
    }
    return false;
  }
}
