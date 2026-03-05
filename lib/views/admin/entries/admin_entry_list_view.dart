import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:product/controllers/entry_controller.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/models/entry_model.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/theme/app_theme.dart';
import 'package:product/views/common/list_form_widgets.dart';
import 'package:product/views/common/role_guard.dart';

class AdminEntryListView extends StatefulWidget {
  const AdminEntryListView({super.key});

  @override
  State<AdminEntryListView> createState() => _AdminEntryListViewState();
}

class _AdminEntryListViewState extends State<AdminEntryListView> {
  final EntryController entryController = Get.find<EntryController>();
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: CompactGradientFab(
          heroTag: 'fab_admin_entries',
          label: 'Ajouter',
          onPressed: () => Get.toNamed(AppRoutes.adminEntryForm),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
          child: SafeArea(
            child: Obx(() {
              final items = _filtered(entryController.entries);
              return RefreshIndicator(
                onRefresh: entryController.loadAllEntries,
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
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(
                              (Get.width * 0.035).clamp(10.0, 12.0),
                            ),
                            decoration: AppTheme.glassCard(),
                            child: Text(
                              'Entrees de Stock',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: (Get.width * 0.05).clamp(18.0, 22.0),
                                color: const Color(0xFF151D2F),
                              ),
                            ),
                          ),
                          SizedBox(height: gap),
                          SearchCardField(
                            controller: _searchController,
                            onChanged: (value) => setState(
                              () => _query = value.trim().toLowerCase(),
                            ),
                            hintText: 'Rechercher une entree',
                          ),
                          SizedBox(height: gap),
                          if (entryController.isLoading.value)
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
                              itemBuilder: (_, index) => _entryCard(items[index]),
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

  List<Entry> _filtered(List<Entry> entries) {
    if (_query.isEmpty) {
      return entries;
    }
    return entries.where((entry) {
      final name = productController.getProductById(entry.productId)?.name ?? '';
      return name.toLowerCase().contains(_query) || entry.quantity.toString().contains(_query);
    }).toList();
  }

  Widget _entryCard(Entry entry) {
    final product = productController.getProductById(entry.productId);
    final date = DateTime.tryParse(entry.date) ?? DateTime.now();
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(entry),
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
                color: Color(0xFFDFF4F1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_received_rounded, color: AppTheme.cashierPrimary),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F7F3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '+${entry.quantity} unites',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E8D80),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
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
          const Icon(Icons.inbox_rounded, size: 42, color: Color(0xFF8F97B0)),
          const SizedBox(height: 10),
          Text(
            'Aucune entree enregistree',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B738D),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(Entry entry) async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer cette entree'),
        content: const Text('La suppression restaurera le stock precedent.'),
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
      await entryController.deleteEntry(entry.id);
      return true;
    }
    return false;
  }
}
