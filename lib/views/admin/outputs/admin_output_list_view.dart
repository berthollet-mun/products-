import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:product/controllers/output_controller.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/models/output_model.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/theme/app_theme.dart';
import 'package:product/views/common/list_form_widgets.dart';
import 'package:product/views/common/role_guard.dart';

class AdminOutputListView extends StatefulWidget {
  const AdminOutputListView({super.key});

  @override
  State<AdminOutputListView> createState() => _AdminOutputListViewState();
}

class _AdminOutputListViewState extends State<AdminOutputListView> {
  final OutputController outputController = Get.find<OutputController>();
  final ProductController productController = Get.find<ProductController>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final horizontalPadding = (width * 0.045).clamp(14.0, 22.0);
    final gap = (Get.height * 0.015).clamp(10.0, 16.0);
    final maxWidth = math.min(width, 760.0);

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
          child: SafeArea(
            child: Obx(() {
              final items = _filtered(outputController.outputs);
              return RefreshIndicator(
                onRefresh: outputController.loadAllOutputs,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    gap,
                    horizontalPadding,
                    gap,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        children: [
                          PageActionHeader(
                            title: 'Sorties de Stock',
                            buttonLabel: 'Ajouter',
                            onPressed: () => Get.toNamed(AppRoutes.adminOutputForm),
                          ),
                          SizedBox(height: gap),
                          SearchCardField(
                            controller: _searchController,
                            onChanged: (value) => setState(
                              () => _query = value.trim().toLowerCase(),
                            ),
                            hintText: 'Rechercher une sortie',
                          ),
                          SizedBox(height: gap),
                          if (outputController.isLoading.value)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            )
                          else if (items.isEmpty)
                            _emptyState()
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (_, index) => _outputCard(items[index]),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  List<Output> _filtered(List<Output> outputs) {
    if (_query.isEmpty) {
      return outputs;
    }
    return outputs.where((output) {
      final name = productController.getProductById(output.productId)?.name ?? '';
      return name.toLowerCase().contains(_query) || output.quantity.toString().contains(_query);
    }).toList();
  }

  Widget _outputCard(Output output) {
    final product = productController.getProductById(output.productId);
    final date = DateTime.tryParse(output.date) ?? DateTime.now();
    final amount = (product?.price ?? 0) * output.quantity;

    return Dismissible(
      key: ValueKey(output.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(output),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEC),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC73838)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all((Get.width * 0.04).clamp(12.0, 16.0)),
        decoration: AppTheme.glassCard(),
        child: Row(
          children: [
            Container(
              width: (Get.width * 0.12).clamp(44.0, 52.0),
              height: (Get.width * 0.12).clamp(44.0, 52.0),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEFE3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_made_rounded, color: Color(0xFFDA8B2E)),
            ),
            SizedBox(width: (Get.width * 0.03).clamp(8.0, 12.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      product?.name ?? 'Produit inconnu',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: const Color(0xFF151D2F),
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(date),
                    style: GoogleFonts.poppins(color: const Color(0xFF707792), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEFE3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '-${output.quantity} unites',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFC67B1E),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9EEFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${amount.toStringAsFixed(2)} EUR',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF315DAE),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((Get.width * 0.06).clamp(18.0, 26.0)),
      decoration: AppTheme.glassCard(),
      child: Column(
        children: [
          const Icon(Icons.outbox_rounded, size: 42, color: Color(0xFF8F97B0)),
          const SizedBox(height: 10),
          Text(
            'Aucune sortie enregistree',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B738D),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(Output output) async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer cette sortie'),
        content: const Text('La suppression restaurera le stock correspondant.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await outputController.deleteOutput(output.id);
      return true;
    }
    return false;
  }
}
