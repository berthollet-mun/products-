import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:product/controllers/output_controller.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/views/common/role_guard.dart';

class AdminOutputListView extends StatelessWidget {
  const AdminOutputListView({super.key});

  @override
  Widget build(BuildContext context) {
    final outputController = Get.find<OutputController>();
    final productController = Get.find<ProductController>();

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historique des Sorties'),
          actions: [
            IconButton(
              onPressed: () => outputController.loadAllOutputs(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Obx(() {
          if (outputController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (outputController.outputs.isEmpty) {
            return const Center(child: Text('Aucune sortie enregistree'));
          }

          return ListView.builder(
            itemCount: outputController.outputs.length,
            itemBuilder: (context, index) {
              final output = outputController.outputs[index];
              final product = productController.getProductById(
                output.productId,
              );
              final date = DateTime.tryParse(output.date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.arrow_upward, color: Colors.orange),
                  title: Text(product?.name ?? 'Produit inconnu'),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy HH:mm').format(date ?? DateTime.now())}\nQuantite: ${output.quantity}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed(AppRoutes.adminOutputForm),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
