import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/output_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/responsive_helper.dart';

class CashierOutputFormView extends StatefulWidget {
  const CashierOutputFormView({super.key});

  @override
  State<CashierOutputFormView> createState() => _CashierOutputFormViewState();
}

class _CashierOutputFormViewState extends State<CashierOutputFormView> {
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
        title: const Text('Enregistrer une Vente'),
        backgroundColor: Colors.teal.shade700,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 20 : 16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.teal.shade700,
                          size: isDesktop ? 32 : 28,
                        ),
                        SizedBox(width: isDesktop ? 16 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nouvelle Vente',
                                style: TextStyle(
                                  fontSize: isDesktop ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              SizedBox(height: isDesktop ? 4 : 2),
                              Text(
                                'Sélectionnez un produit et entrez la quantité vendue',
                                style: TextStyle(
                                  fontSize: isDesktop ? 16 : 14,
                                  color: Colors.teal.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),

                  // Product Selection
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
                        labelText: 'Sélectionner un produit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 12 : 8,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.inventory_2,
                          color: Colors.teal.shade700,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 20 : 16,
                        ),
                      ),
                      items: productController.products
                          .where((p) => p.quantity > 0)
                          .map((product) {
                            return DropdownMenuItem(
                              value: product.id,
                              child: Text(
                                '${product.name} (Stock: ${product.quantity} | Prix: ${product.price}€)',
                                style: TextStyle(fontSize: isDesktop ? 16 : 14),
                              ),
                            );
                          })
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedProductId = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner un produit';
                        }
                        return null;
                      },
                    );
                  }),
                  SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),

                  // Quantity Field
                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantité vendue',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      ),
                      prefixIcon: Icon(
                        Icons.numbers,
                        color: Colors.teal.shade700,
                      ),
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
                        return 'La quantité est requise';
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

                  // Date Field
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date de vente',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      ),
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.teal.shade700,
                      ),
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

                  // Summary Card
                  if (selectedProductId != null &&
                      quantityController.text.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: isDesktop ? 32 : 24),
                      padding: EdgeInsets.all(isDesktop ? 24 : 16),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                      child: Obx(() {
                        final product = Get.find<ProductController>().products
                            .firstWhereOrNull((p) => p.id == selectedProductId);
                        final quantity =
                            int.tryParse(quantityController.text) ?? 0;
                        final total = (product?.price ?? 0) * quantity;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Prix unitaire:',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 14,
                                  ),
                                ),
                                Text(
                                  '${product?.price ?? 0}€',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isDesktop ? 12 : 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quantité:',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 14,
                                  ),
                                ),
                                Text(
                                  quantity.toString(),
                                  style: TextStyle(
                                    fontSize: isDesktop ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TOTAL:',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                Text(
                                  '${total.toStringAsFixed(2)}€',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),

                  SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),
                  SizedBox(
                    width: double.infinity,
                    height: isDesktop ? 56 : (isTablet ? 52 : 48),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 12 : 8,
                          ),
                        ),
                      ),
                      onPressed: _handleSubmit,
                      child: Text(
                        'VALIDER LA VENTE',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
      Get.snackbar(
        'Succès',
        'Vente enregistrée avec succès!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar('Erreur', 'Impossible d\'enregistrer la vente');
    }
  }
}
