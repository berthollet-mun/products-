import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/entry_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/responsive_helper.dart';

class AdminEntryFormView extends StatefulWidget {
  const AdminEntryFormView({super.key});

  @override
  State<AdminEntryFormView> createState() => _AdminEntryFormViewState();
}

class _AdminEntryFormViewState extends State<AdminEntryFormView> {
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
        title: const Text('Entrée de Stock'),
        backgroundColor: Colors.green.shade700,
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
                            product.name,
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
                      labelText: 'Quantité',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      ),
                      prefixIcon: const Icon(Icons.numbers),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 20 : 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantité requise';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Quantité invalide';
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
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 12 : 8,
                          ),
                        ),
                      ),
                      onPressed: _handleSubmit,
                      child: Text(
                        'Enregistrer l\'entrée',
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

    final entryController = Get.find<EntryController>();
    final auth = Get.find<AuthController>();

    final success = await entryController.createEntry(
      productId: selectedProductId!,
      quantity: int.parse(quantityController.text),
      userId: auth.currentUser?.id ?? 'unknown',
    );

    if (success) {
      Get.back();
      Get.snackbar('Succès', 'Entrée de stock enregistrée');
    } else {
      Get.snackbar('Erreur', 'Impossible d\'enregistrer l\'entrée');
    }
  }
}
