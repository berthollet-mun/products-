import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/output_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/responsive_helper.dart';

class AdminOutputFormView extends StatefulWidget {
  const AdminOutputFormView({super.key});

  @override
  State<AdminOutputFormView> createState() => _AdminOutputFormViewState();
}

class _AdminOutputFormViewState extends State<AdminOutputFormView> {
  late TextEditingController quantityController;
  late TextEditingController dateController;
  String? selectedProductId;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController();
    dateController = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sortie de Stock / Vente'),
        backgroundColor: Colors.orange.shade700,
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
                  Obx(() {
                    if (productController.products.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(isDesktop ? 16 : 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 12 : 8,
                          ),
                        ),
                        child: Text(
                          'Aucun produit disponible',
                          style: TextStyle(fontSize: isDesktop ? 18 : 16),
                        ),
                      );
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: selectedProductId,
                      decoration: InputDecoration(
                        labelText: 'Produit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 12 : 8,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.inventory_2),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 20 : 16,
                        ),
                      ),
                      items: productController.products.map((product) {
                        return DropdownMenuItem(
                          value: product.id,
                          child: Text(
                            '${product.name} (Stock: ${product.quantity})',
                            style: TextStyle(fontSize: isDesktop ? 16 : 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedProductId = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Sélectionnez un produit';
                        }
                        return null;
                      },
                    );
                  }),
                  SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantité à vendre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      ),
                      prefixIcon: const Icon(Icons.numbers),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 20 : 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Trigger rebuild to update validation
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantité requise';
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return 'Quantité invalide';
                      }

                      if (selectedProductId != null) {
                        final product = Get.find<ProductController>().products
                            .firstWhereOrNull((p) => p.id == selectedProductId);
                        if (product != null && qty > product.quantity) {
                          return 'Stock insuffisant (${product.quantity} disponible)';
                        }
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 20 : 16,
                      ),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        dateController.text = date.toString().split(' ')[0];
                      }
                    },
                  ),
                  SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),
                  SizedBox(
                    width: double.infinity,
                    height: isDesktop ? 56 : (isTablet ? 52 : 48),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 12 : 8,
                          ),
                        ),
                      ),
                      onPressed: _handleSubmit,
                      child: Text(
                        'Enregistrer la vente',
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

    final outputController = Get.find<OutputController>();
    final auth = Get.find<AuthController>();
    final productController = Get.find<ProductController>();

    // Get product for price calculation
    final product = productController.products.firstWhereOrNull(
      (p) => p.id == selectedProductId,
    );

    if (product == null) {
      Get.snackbar('Erreur', 'Produit non trouvé');
      return;
    }

    final success = await outputController.createOutput(
      productId: selectedProductId!,
      quantity: int.parse(quantityController.text),
      userId: auth.currentUser?.id ?? 'unknown',
    );

    if (success) {
      Get.back();
      Get.snackbar('Succès', 'Vente enregistrée');
    } else {
      Get.snackbar('Erreur', 'Impossible d\'enregistrer la vente');
    }
  }
}
