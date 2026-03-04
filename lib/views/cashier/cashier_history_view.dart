import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:product/controllers/auth_controller.dart';
import 'package:product/controllers/output_controller.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:product/views/common/role_guard.dart';

class CashierHistoryView extends StatelessWidget {
  const CashierHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final outputController = Get.find<OutputController>();
    final productController = Get.find<ProductController>();

    return RoleGuard(
      requiredRole: 'caissier',
      child: Scaffold(
        appBar: AppBar(title: const Text('Historique Caissier')),
        body: Obx(() {
          final userId = authController.currentUser.value?.id;
          if (userId == null) {
            return const Center(child: Text('Utilisateur non connecte'));
          }

          final myOutputs =
              outputController.outputs
                  .where((output) => output.userId == userId)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));

          if (myOutputs.isEmpty) {
            return const Center(
              child: Text('Aucune operation pour ce caissier'),
            );
          }

          return ListView.builder(
            itemCount: myOutputs.length,
            itemBuilder: (context, index) {
              final output = myOutputs[index];
              final product = productController.getProductById(
                output.productId,
              );
              final date = DateTime.tryParse(output.date);
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(product?.name ?? 'Produit'),
                subtitle: Text(
                  '${DateFormat('dd/MM/yyyy HH:mm').format(date ?? DateTime.now())} - Quantite: ${output.quantity}',
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
