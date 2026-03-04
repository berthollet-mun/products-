import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:product/controllers/entry_controller.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/views/common/role_guard.dart';

class AdminEntryListView extends StatelessWidget {
  const AdminEntryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final entryController = Get.find<EntryController>();
    final productController = Get.find<ProductController>();

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historique des Entrees'),
          actions: [
            IconButton(
              onPressed: () => entryController.loadAllEntries(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Obx(() {
          if (entryController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (entryController.entries.isEmpty) {
            return const Center(child: Text('Aucune entree enregistree'));
          }

          return ListView.builder(
            itemCount: entryController.entries.length,
            itemBuilder: (context, index) {
              final entry = entryController.entries[index];
              final product = productController.getProductById(entry.productId);
              final date = DateTime.tryParse(entry.date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const Icon(
                    Icons.arrow_downward,
                    color: Colors.green,
                  ),
                  title: Text(product?.name ?? 'Produit inconnu'),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy HH:mm').format(date ?? DateTime.now())}\nQuantite: ${entry.quantity}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed(AppRoutes.adminEntryForm),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
