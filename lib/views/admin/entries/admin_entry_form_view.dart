import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/controllers/auth_controller.dart';
import 'package:product/controllers/entry_controller.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/theme/app_theme.dart';
import 'package:product/views/common/list_form_widgets.dart';
import 'package:product/views/common/role_guard.dart';

class AdminEntryFormView extends StatefulWidget {
  const AdminEntryFormView({super.key});

  @override
  State<AdminEntryFormView> createState() => _AdminEntryFormViewState();
}

class _AdminEntryFormViewState extends State<AdminEntryFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedProductId;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
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
                          _titleRow('Ajouter Entree'),
                          const SizedBox(height: 20),
                          Obx(() {
                            if (productController.products.isEmpty) {
                              return Text(
                                'Aucun produit disponible',
                                style: GoogleFonts.poppins(color: const Color(0xFF707792)),
                              );
                            }
                            return DropdownButtonFormField<String>(
                              initialValue: _selectedProductId,
                              decoration: const InputDecoration(
                                hintText: 'Produit',
                                prefixIcon: Icon(
                                  Icons.inventory_2_rounded,
                                  color: AppTheme.adminPrimary,
                                ),
                              ),
                              items: productController.products
                                  .map(
                                    (product) => DropdownMenuItem<String>(
                                      value: product.id,
                                      child: Text(product.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setState(() => _selectedProductId = value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selectionnez un produit';
                                }
                                return null;
                              },
                            );
                          }),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Quantite',
                              prefixIcon: Icon(
                                Icons.numbers_rounded,
                                color: AppTheme.adminPrimary,
                              ),
                            ),
                            validator: (value) {
                              final qty = int.tryParse(value ?? '');
                              if (qty == null || qty <= 0) {
                                return 'Quantite invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          GradientSubmitButton(label: 'Enregistrer', onPressed: _submit),
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

  Widget _titleRow(String title) {
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
              title,
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
