import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/controllers/auth_controller.dart';
import 'package:product/controllers/entry_controller.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/views/common/role_guard.dart';

class AdminEntryFormView extends StatefulWidget {
  const AdminEntryFormView({super.key});

  @override
  State<AdminEntryFormView> createState() => _AdminEntryFormViewState();
}

class _AdminEntryFormViewState extends State<AdminEntryFormView> {
  late final TextEditingController _quantityController;
  String? _selectedProductId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        appBar: AppBar(title: const Text('Ajouter une Entree')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Obx(() {
                  if (productController.products.isEmpty) {
                    return const Text('Aucun produit disponible');
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedProductId,
                    decoration: const InputDecoration(
                      labelText: 'Produit',
                      border: OutlineInputBorder(),
                    ),
                    items: productController.products
                        .map(
                          (product) => DropdownMenuItem<String>(
                            value: product.id,
                            child: Text(product.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedProductId = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selectionnez un produit';
                      }
                      return null;
                    },
                  );
                }),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantite',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final quantity = int.tryParse(value ?? '');
                    if (quantity == null || quantity <= 0) {
                      return 'Quantite invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Enregistrer'),
                  ),
                ),
              ],
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

    final entryController = Get.find<EntryController>();
    final authController = Get.find<AuthController>();
    final userId = authController.currentUser.value?.id;

    if (userId == null || _selectedProductId == null) {
      Get.snackbar('Erreur', 'Utilisateur ou produit invalide');
      return;
    }

    final success = await entryController.createEntry(
      productId: _selectedProductId!,
      quantity: int.parse(_quantityController.text),
      userId: userId,
    );

    if (success) {
      Get.back();
    }
  }
}
