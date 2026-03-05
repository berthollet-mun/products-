import 'package:get/get.dart';
import 'package:product/bindings/auth_binding.dart';
import 'package:product/bindings/dashboard_binding.dart';
import 'package:product/bindings/entry_binding.dart';
import 'package:product/bindings/output_binding.dart';
import 'package:product/bindings/product_binding.dart';
import 'package:product/bindings/user_binding.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/views/admin/admin_dashboard_view.dart';
import 'package:product/views/admin/entries/admin_entry_form_view.dart';
import 'package:product/views/admin/entries/admin_entry_list_view.dart';
import 'package:product/views/admin/outputs/admin_output_form_view.dart';
import 'package:product/views/admin/outputs/admin_output_list_view.dart';
import 'package:product/views/admin/products/admin_product_form_view.dart';
import 'package:product/views/admin/products/admin_product_list_view.dart';
import 'package:product/views/admin/users/admin_user_form_view.dart';
import 'package:product/views/admin/users/admin_user_list_view.dart';
import 'package:product/views/cashier/cashier_dashboard_view.dart';
import 'package:product/views/cashier/cashier_history_view.dart';
import 'package:product/views/cashier/cashier_output_form_view.dart';
import 'package:product/views/cashier/cashier_output_list_view.dart';
import 'package:product/views/cashier/cashier_product_list_view.dart';
import 'package:product/views/user/login_view.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      bindings: [AuthBinding(), DashboardBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.cashierDashboard,
      page: () => const CashierDashboardView(),
      bindings: [AuthBinding(), DashboardBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminProductList,
      page: () => const AdminProductListView(),
      bindings: [AuthBinding(), ProductBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminProductForm,
      page: () => const AdminProductFormView(),
      bindings: [AuthBinding(), ProductBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminEntryList,
      page: () => const AdminEntryListView(),
      bindings: [AuthBinding(), ProductBinding(), EntryBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminEntryForm,
      page: () => const AdminEntryFormView(),
      bindings: [AuthBinding(), ProductBinding(), EntryBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminOutputList,
      page: () => const AdminOutputListView(),
      bindings: [AuthBinding(), ProductBinding(), OutputBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminOutputForm,
      page: () => const AdminOutputFormView(),
      bindings: [AuthBinding(), ProductBinding(), OutputBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminUserList,
      page: () => const AdminUserListView(),
      bindings: [AuthBinding(), UserBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminUserForm,
      page: () => const AdminUserFormView(),
      bindings: [AuthBinding(), UserBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.cashierProductList,
      page: () => const CashierProductListView(),
      bindings: [AuthBinding(), ProductBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.cashierOutputForm,
      page: () => const CashierOutputFormView(),
      bindings: [AuthBinding(), ProductBinding(), OutputBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.cashierOutputList,
      page: () => const CashierOutputListView(),
      bindings: [AuthBinding(), ProductBinding(), OutputBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.cashierHistory,
      page: () => const CashierHistoryView(),
      bindings: [AuthBinding(), ProductBinding(), OutputBinding()],
      transition: Transition.fadeIn,
    ),
  ];
}
