import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/controllers/auth_controller.dart';
import 'package:product/controllers/output_controller.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/theme/app_theme.dart';
import 'package:product/views/common/list_form_widgets.dart';
import 'package:product/views/common/role_guard.dart';

class CashierOutputFormView extends StatefulWidget {
  const CashierOutputFormView({super.key});

  @override
  State<CashierOutputFormView> createState() => _CashierOutputFormViewState();
}

class _CashierOutputFormViewState extends State<CashierOutputFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
    text: DateTime.now().toString().split(' ')[0],
  );
  String? _selectedProductId;

  @override
  void dispose() {
    _quantityController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final width = Get.width;
    final maxWidth = math.min(width, 720.0);
    final horizontalPadding = (width * 0.05).clamp(14.0, 24.0);

    return RoleGuard(
      requiredRole: 'caissier',
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
                          _titleRow('Enregistrer Vente'),
                          const SizedBox(height: 20),
                          Obx(() {
                            final available = productController.products
                                .where((p) => p.quantity > 0)
                                .toList();
                            if (available.isEmpty) {
                              return Text(
                                'Aucun produit disponible',
                                style: GoogleFonts.poppins(color: const Color(0xFF707792)),
                              );
                            }
                            return DropdownButtonFormField<String>(
                              initialValue: _selectedProductId,
                              decoration: const InputDecoration(
                                hintText: 'Selectionner un produit',
                                prefixIcon: Icon(
                                  Icons.inventory_2_rounded,
                                  color: AppTheme.cashierPrimary,
                                ),
                              ),
                              items: available
                                  .map(
                                    (product) => DropdownMenuItem<String>(
                                      value: product.id,
                                      child: Text(
                                        '${product.name} (Stock: ${product.quantity})',
                                      ),
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
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Quantite vendue',
                              prefixIcon: Icon(
                                Icons.numbers_rounded,
                                color: AppTheme.cashierPrimary,
                              ),
                            ),
                            validator: (value) {
                              final qty = int.tryParse(value ?? '');
                              if (qty == null || qty <= 0) {
                                return 'Quantite invalide';
                              }
                              if (_selectedProductId != null) {
                                final product = Get.find<ProductController>().products
                                    .firstWhereOrNull((p) => p.id == _selectedProductId);
                                if (product != null && qty > product.quantity) {
                                  return 'Stock insuffisant (${product.quantity} disponible)';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: 'Date',
                              prefixIcon: Icon(
                                Icons.calendar_today_rounded,
                                color: AppTheme.cashierPrimary,
                              ),
                            ),
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: 20),
                          Obx(() {
                            final product = productController.products
                                .firstWhereOrNull((p) => p.id == _selectedProductId);
                            final quantity = int.tryParse(_quantityController.text) ?? 0;
                            final total = (product?.price ?? 0) * quantity;
                            if (product == null || quantity <= 0) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all((Get.width * 0.04).clamp(12.0, 16.0)),
                              decoration: AppTheme.glassCard(color: const Color(0xFFEFF9F8)),
                              child: Wrap(
                                runSpacing: 8,
                                children: [
                                  _summaryRow('Produit', product.name),
                                  _summaryRow('Prix unitaire', '${product.price.toStringAsFixed(2)} EUR'),
                                  _summaryRow('Quantite', quantity.toString()),
                                  _summaryRow('Total', '${total.toStringAsFixed(2)} EUR'),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          GradientSubmitButton(
                            label: 'Enregistrer',
                            onPressed: _submit,
                            isCashier: true,
                            icon: Icons.point_of_sale_rounded,
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

  Widget _titleRow(String title) {
    return Row(
      children: [
        IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.cashierDark),
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

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF5E6782),
            fontWeight: FontWeight.w500,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: AppTheme.cashierDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _dateController.text = date.toString().split(' ')[0];
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final outputController = Get.find<OutputController>();
    final authController = Get.find<AuthController>();
    final userId = authController.currentUser.value?.id;

    if (userId == null || _selectedProductId == null) {
      Get.snackbar('Erreur', 'Utilisateur ou produit invalide');
      return;
    }

    final success = await outputController.createOutput(
      productId: _selectedProductId!,
      quantity: int.parse(_quantityController.text),
      userId: userId,
    );

    if (!success) return;
  }
}
