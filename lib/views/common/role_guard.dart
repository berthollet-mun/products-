import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/controllers/auth_controller.dart';
import 'package:product/routes/app_routes.dart';

class RoleGuard extends StatelessWidget {
  final String requiredRole;
  final Widget child;

  const RoleGuard({super.key, required this.requiredRole, required this.child});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      if (authController.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (!authController.isLoggedIn.value ||
          authController.currentUser.value == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppRoutes.login);
        });
        return const Scaffold(body: SizedBox.shrink());
      }

      if (authController.currentRole.value != requiredRole) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final target = requiredRole == 'admin'
              ? AppRoutes.cashierDashboard
              : AppRoutes.adminDashboard;
          Get.offAllNamed(target);
        });
        return const Scaffold(body: SizedBox.shrink());
      }

      return child;
    });
  }
}
