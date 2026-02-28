import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/utils/responsive_helper.dart';

import '../../controllers/product_controller.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final Color _primaryColor = const Color(0xFF1E3A8A);

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Widget réutilisable pour les champs de texte (Design translucide)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    int lines = 1,
  }) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(isDesktop ? 18 : 15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: lines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(
            icon,
            color: Colors.white70,
            size: isDesktop ? 24 : 22,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isDesktop ? 20 : 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Obx(() {
      final controller = Get.find<ProductController>();
      final isBusy = controller.isLoading.value;

      return Scaffold(
        backgroundColor: const Color(0xFF1E0701),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E0701),
          elevation: 0,
          title: Text(
            'Nouveau Produit',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 24 : 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 700 : (isTablet ? 600 : double.infinity),
              ),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Nom du produit',
                    icon: Icons.shopping_bag_outlined,
                  ),
                  _buildTextField(
                    controller: _skuController,
                    hint: 'Référence SKU (Unique)',
                    icon: Icons.qr_code_2_rounded,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _priceController,
                          hint: 'Prix (€)',
                          icon: Icons.euro_symbol_rounded,
                          type: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: isDesktop ? 24 : 15),
                      Expanded(
                        child: _buildTextField(
                          controller: _qtyController,
                          hint: 'Quantité',
                          icon: Icons.numbers_rounded,
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  _buildTextField(
                    controller: _descController,
                    hint: 'Description (Optionnel)',
                    icon: Icons.notes_rounded,
                    lines: 3,
                  ),
                  SizedBox(height: isDesktop ? 40 : 30),

                  // BOUTON VALIDER
                  SizedBox(
                    width: double.infinity,
                    height: isDesktop ? 60 : 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 18 : 15,
                          ),
                        ),
                      ),
                      onPressed: isBusy
                          ? null
                          : () async {
                              final success =
                                  await Get.find<ProductController>()
                                      .createNewProduct(
                                        name: _nameController.text,
                                        sku: _skuController.text,
                                        price:
                                            double.tryParse(
                                              _priceController.text,
                                            ) ??
                                            -1,
                                        quantity:
                                            int.tryParse(_qtyController.text) ??
                                            -1,
                                        description: _descController.text,
                                      );

                              if (success) {
                                if (context.mounted) {
                                  Navigator.pop(context, {'success': true});
                                }
                              }
                            },
                      child: isBusy
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'ENREGISTRER LE PRODUIT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: isDesktop ? 18 : 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
