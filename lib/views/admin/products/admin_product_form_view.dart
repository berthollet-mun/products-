import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/product.dart';
import '../../../utils/responsive_helper.dart';

class AdminProductFormView extends StatefulWidget {
  final Product? product;
  const AdminProductFormView({super.key, this.product});

  @override
  State<AdminProductFormView> createState() => _AdminProductFormViewState();
}

class _AdminProductFormViewState extends State<AdminProductFormView> {
  late TextEditingController nameController;
  late TextEditingController skuController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController descriptionController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product?.name ?? '');
    skuController = TextEditingController(text: widget.product?.sku ?? '');
    priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    quantityController = TextEditingController(
      text: widget.product?.quantity.toString() ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    skuController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Ajouter un produit' : 'Modifier le produit',
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 16)),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 800 : (isTablet ? 600 : double.infinity),
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom du produit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      ),
                      prefixIcon: const Icon(Icons.shopping_bag),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 20 : 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom est requis';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                  TextFormField(
                    controller: skuController,
                    decoration: InputDecoration(
                      labelText: 'Code SKU',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      ),
                      prefixIcon: const Icon(Icons.qr_code),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 20 : 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le SKU est requis';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Prix (€)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                isDesktop ? 12 : 8,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.euro_symbol),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 20 : 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Prix requis';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Valeur invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: isDesktop ? 24 : (isTablet ? 20 : 16)),
                      Expanded(
                        child: TextFormField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Stock',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                isDesktop ? 12 : 8,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.numbers),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 20 : 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Stock requis';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Valeur invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: isDesktop ? 5 : 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      ),
                      prefixIcon: const Icon(Icons.notes),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 20 : 16,
                        horizontal: isDesktop ? 16 : 12,
                      ),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),
                  SizedBox(
                    width: double.infinity,
                    height: isDesktop ? 56 : (isTablet ? 52 : 48),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 12 : 8,
                          ),
                        ),
                      ),
                      onPressed: _handleSubmit,
                      child: Text(
                        widget.product == null
                            ? 'Créer le produit'
                            : 'Mettre à jour',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          color: Colors.white,
                        ),
                      ),
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

  Future<void> _handleSubmit() async {
    if (!formKey.currentState!.validate()) return;

    final controller = Get.find<ProductController>();

    if (widget.product == null) {
      // Create new product
      final success = await controller.createNewProduct(
        name: nameController.text.trim(),
        sku: skuController.text.trim().toUpperCase(),
        price: double.parse(priceController.text),
        quantity: int.parse(quantityController.text),
        description: descriptionController.text.trim(),
      );

      if (success) {
        Get.back();
        Get.snackbar('Succès', 'Produit créé');
      }
    } else {
      // Update existing product
      final updatedProduct = Product(
        id: widget.product!.id,
        name: nameController.text.trim(),
        sku: skuController.text.trim().toUpperCase(),
        price: double.parse(priceController.text),
        quantity: int.parse(quantityController.text),
        description: descriptionController.text.trim(),
      );

      final success = await controller.updateProduct(updatedProduct);
      if (success) {
        Get.back();
        Get.snackbar('Succès', 'Produit mis à jour');
      }
    }
  }
}
