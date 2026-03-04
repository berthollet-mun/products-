import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/models/product.dart';
import 'package:product/utils/responsive_helper.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.product?.quantity.toString() ?? '',
    );
    _stockMinimumController = TextEditingController(
      text: (widget.product?.stockMinimum ?? 5).toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
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
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.product == null
                ? 'Ajouter un produit'
                : 'Modifier le produit',
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 16)),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : (isTablet ? 600 : double.infinity),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du produit',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Nom requis'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(
                        labelText: 'Code SKU',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'SKU requis'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Prix invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock actuel',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed < 0) {
                          return 'Stock invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stockMinimumController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock minimum',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed < 0) {
                          return 'Stock minimum invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text(
                          widget.product == null ? 'Creer' : 'Mettre a jour',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final controller = Get.find<ProductController>();
    final stockMinimum = int.parse(_stockMinimumController.text);

    if (widget.product == null) {
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

    final updatedProduct = Product(
      id: widget.product!.id,
      name: _nameController.text.trim(),
      sku: _skuController.text.trim().toUpperCase(),
      price: double.parse(_priceController.text),
      quantity: int.parse(_quantityController.text),
      stockMinimum: stockMinimum,
      createdAt: widget.product!.createdAt,
      description: _descriptionController.text.trim(),
    );

    final success = await controller.updateProduct(updatedProduct);
    if (success) {
      Get.back();
    }
  }
}
