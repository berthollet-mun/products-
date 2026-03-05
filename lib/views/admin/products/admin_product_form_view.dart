import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/models/product.dart';
import 'package:product/theme/app_theme.dart';
import 'package:product/views/common/list_form_widgets.dart';
import 'package:product/views/common/role_guard.dart';

class AdminProductFormView extends StatefulWidget {
  final Product? product;
  const AdminProductFormView({super.key, this.product});

  @override
  State<AdminProductFormView> createState() => _AdminProductFormViewState();
}

class _AdminProductFormViewState extends State<AdminProductFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _stockMinimumController;
  late final TextEditingController _descriptionController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Product? _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product ?? Get.arguments as Product?;
    _nameController = TextEditingController(text: _currentProduct?.name ?? '');
    _skuController = TextEditingController(text: _currentProduct?.sku ?? '');
    _priceController = TextEditingController(
      text: _currentProduct?.price.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: _currentProduct?.quantity.toString() ?? '',
    );
    _stockMinimumController = TextEditingController(
      text: (_currentProduct?.stockMinimum ?? 5).toString(),
    );
    _descriptionController = TextEditingController(
      text: _currentProduct?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _stockMinimumController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final maxWidth = math.min(width, 720.0);
    final horizontalPadding = (width * 0.05).clamp(14.0, 24.0);

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                (Get.height * 0.015).clamp(10.0, 18.0),
                horizontalPadding,
                (Get.height * 0.02).clamp(14.0, 24.0),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Container(
                    padding: EdgeInsets.all((width * 0.05).clamp(14.0, 22.0)),
                    decoration: AppTheme.glassCard(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _titleRow(),
                          const SizedBox(height: 20),
                          _field(
                            controller: _nameController,
                            hintText: 'Nom du produit',
                            icon: Icons.inventory_2_rounded,
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'Nom requis'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _field(
                            controller: _skuController,
                            hintText: 'Code SKU',
                            icon: Icons.qr_code_rounded,
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'SKU requis'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _field(
                            controller: _priceController,
                            hintText: 'Prix achat/vente',
                            icon: Icons.euro_rounded,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final parsed = double.tryParse(value ?? '');
                              if (parsed == null || parsed <= 0) {
                                return 'Prix invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _field(
                            controller: _quantityController,
                            hintText: 'Stock actuel',
                            icon: Icons.numbers_rounded,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final parsed = int.tryParse(value ?? '');
                              if (parsed == null || parsed < 0) {
                                return 'Stock invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _field(
                            controller: _stockMinimumController,
                            hintText: 'Stock minimum',
                            icon: Icons.warning_amber_rounded,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final parsed = int.tryParse(value ?? '');
                              if (parsed == null || parsed < 0) {
                                return 'Stock minimum invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _field(
                            controller: _descriptionController,
                            hintText: 'Description',
                            icon: Icons.notes_rounded,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),
                          GradientSubmitButton(
                            label: _currentProduct == null ? 'Ajouter' : 'Mettre a jour',
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleRow() {
    return Row(
      children: [
        IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.adminDark),
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _currentProduct == null ? 'Ajouter Produit' : 'Modifier Produit',
              style: GoogleFonts.poppins(
                fontSize: (Get.width * 0.07).clamp(24.0, 32.0),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF151D2F),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppTheme.adminPrimary),
      ),
      validator: validator,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = Get.find<ProductController>();
    final stockMinimum = int.parse(_stockMinimumController.text);

    if (_currentProduct == null) {
      final success = await controller.createNewProduct(
        name: _nameController.text.trim(),
        sku: _skuController.text.trim().toUpperCase(),
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        stockMinimum: stockMinimum,
        description: _descriptionController.text.trim(),
      );
      if (success) {
        Get.back();
      }
      return;
    }

    final currentProduct = _currentProduct;
    final updatedProduct = Product(
      id: currentProduct.id,
      name: _nameController.text.trim(),
      sku: _skuController.text.trim().toUpperCase(),
      price: double.parse(_priceController.text),
      quantity: int.parse(_quantityController.text),
      stockMinimum: stockMinimum,
      createdAt: currentProduct.createdAt,
      description: _descriptionController.text.trim(),
    );

    final success = await controller.updateProduct(updatedProduct);
    if (success) {
      Get.back();
    }
  }
}
