import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:product/controllers/auth_controller.dart';
import 'package:product/controllers/output_controller.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/models/output_model.dart';
import 'package:product/theme/app_theme.dart';
import 'package:product/views/common/list_form_widgets.dart';
import 'package:product/views/common/role_guard.dart';

class CashierHistoryView extends StatefulWidget {
  const CashierHistoryView({super.key});

  @override
  State<CashierHistoryView> createState() => _CashierHistoryViewState();
}

class _CashierHistoryViewState extends State<CashierHistoryView> {
  final AuthController authController = Get.find<AuthController>();
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
      requiredRole: 'caissier',
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
          child: SafeArea(
            child: Obx(() {
              final userId = authController.currentUser.value?.id;
              if (userId == null) {
                return const Center(child: Text('Utilisateur non connecte'));
              }

              final outputs = outputController.outputs
                  .where((output) => output.userId == userId)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));
              final filtered = _filter(outputs);

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
                            title: 'Historique',
                            buttonLabel: 'Aujourd\'hui',
                            onPressed: () => setState(() => _query = ''),
                            isCashier: true,
                          ),
                          SizedBox(height: gap),
                          SearchCardField(
                            controller: _searchController,
                            onChanged: (value) => setState(
                              () => _query = value.trim().toLowerCase(),
                            ),
                            hintText: 'Rechercher une vente',
                          ),
                          SizedBox(height: gap),
                          if (outputController.isLoading.value)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            )
                          else if (filtered.isEmpty)
                            _emptyState()
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              itemBuilder: (_, index) => _historyCard(filtered[index]),
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

  List<Output> _filter(List<Output> outputs) {
    if (_query.isEmpty) {
      return outputs;
    }
    return outputs.where((output) {
      final name = productController.getProductById(output.productId)?.name ?? '';
      return name.toLowerCase().contains(_query) || output.quantity.toString().contains(_query);
    }).toList();
  }

  Widget _historyCard(Output output) {
    final product = productController.getProductById(output.productId);
    final date = DateTime.tryParse(output.date) ?? DateTime.now();
    final amount = (product?.price ?? 0) * output.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all((Get.width * 0.04).clamp(12.0, 16.0)),
      decoration: AppTheme.glassCard(),
      child: Row(
        children: [
          Container(
            width: (Get.width * 0.12).clamp(44.0, 52.0),
            height: (Get.width * 0.12).clamp(44.0, 52.0),
            decoration: const BoxDecoration(
              color: Color(0xFFDFF4F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppTheme.cashierPrimary),
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
                    product?.name ?? 'Produit',
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
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${output.quantity}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFC94A40),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              Text(
                '+${amount.toStringAsFixed(2)} EUR',
                style: GoogleFonts.poppins(
                  color: AppTheme.cashierDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
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
          const Icon(Icons.history_rounded, size: 42, color: Color(0xFF8F97B0)),
          const SizedBox(height: 10),
          Text(
            'Aucune operation pour ce caissier',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B738D),
            ),
          ),
        ],
      ),
    );
  }
}
