import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/utils/responsive_helper.dart';

import '../../../controllers/product_controller.dart';
import '../../../models/product.dart';

class EditProductForm extends StatefulWidget {
  // On ne demande que la Map, exactement comme pour EditUserForm
  final Map<String, dynamic> productData;

  const EditProductForm({super.key, required this.productData});

  @override
  State<EditProductForm> createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _priceController;
  late TextEditingController _qtyController;
  late TextEditingController _descController;

  final Color _primaryColor = const Color(0xFF1E3A8A);

  @override
  void initState() {
    super.initState();
    // On initialise les champs en utilisant les clés de la Map
    _nameController = TextEditingController(
      text: widget.productData['name']?.toString() ?? '',
    );
    _skuController = TextEditingController(
      text: widget.productData['sku']?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.productData['price']?.toString() ?? '0',
    );
    _qtyController = TextEditingController(
      text: widget.productData['quantity']?.toString() ?? '0',
    );
    _descController = TextEditingController(
      text: widget.productData['description']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _descController.dispose();
    super.dispose();
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white70,
        fontSize: isDesktop ? 16 : 14,
      ),
      prefixIcon: Icon(icon, color: Colors.white, size: isDesktop ? 24 : 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: isDesktop ? 16 : 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
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
            "Modifier le produit",
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 24 : 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 20),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop
                      ? 700
                      : (isTablet ? 600 : double.infinity),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputStyle(
                          'Nom du produit',
                          Icons.inventory_2_outlined,
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? "Nom requis" : null,
                      ),
                      SizedBox(height: isDesktop ? 24 : 16),
                      TextFormField(
                        controller: _skuController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputStyle(
                          'Code SKU',
                          Icons.qr_code_2_rounded,
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? "SKU requis" : null,
                      ),
                      SizedBox(height: isDesktop ? 24 : 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: _inputStyle(
                                'Prix (€)',
                                Icons.euro_symbol_rounded,
                              ),
                              validator: (v) =>
                                  (v == null || double.tryParse(v) == null)
                                  ? "Invalide"
                                  : null,
                            ),
                          ),
                          SizedBox(width: isDesktop ? 20 : 12),
                          Expanded(
                            child: TextFormField(
                              controller: _qtyController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: _inputStyle(
                                'Stock',
                                Icons.numbers_rounded,
                              ),
                              validator: (v) =>
                                  (v == null || int.tryParse(v) == null)
                                  ? "Invalide"
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isDesktop ? 24 : 16),
                      TextFormField(
                        controller: _descController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: _inputStyle(
                          'Description',
                          Icons.notes_rounded,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 48 : 40),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'ANNULER',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: isDesktop ? 16 : 14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isDesktop ? 16 : 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                padding: EdgeInsets.symmetric(
                                  vertical: isDesktop ? 18 : 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    isDesktop ? 16 : 12,
                                  ),
                                ),
                              ),
                              onPressed: isBusy ? null : _handleUpdate,
                              child: isBusy
                                  ? SizedBox(
                                      height: isDesktop ? 24 : 20,
                                      width: isDesktop ? 24 : 20,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'METTRE À JOUR',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: isDesktop ? 18 : 16,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      // 1. Créer l'objet Product complet avec les nouvelles données
      // On récupère l'ID depuis la Map productData passée au widget
      final updatedProduct = Product(
        id: widget.productData['id'],
        name: _nameController.text.trim(),
        sku: _skuController.text.trim().toUpperCase(),
        price: double.parse(_priceController.text),
        quantity: int.parse(_qtyController.text),
        description: _descController.text.trim(),
      );

      // 2. Appeler le controller en passant l'OBJET directement
      // On respecte la signature : Future<String?> UpdatedProduct(Product updatedProduct)
      final success = await Get.find<ProductController>().updateProduct(
        updatedProduct,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, {'success': true});
      }
    }
  }
}
