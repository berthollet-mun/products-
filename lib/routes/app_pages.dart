import 'package:get/get.dart';
import '../bindings/auth_binding.dart';
import '../bindings/product_binding.dart';
import '../bindings/user_binding.dart';
import '../bindings/entry_binding.dart';
import '../bindings/output_binding.dart';
import '../routes/app_routes.dart';
import '../views/user/login_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../views/cashier/cashier_dashboard_view.dart';
import '../views/admin/products/admin_product_list_view.dart';
import '../views/admin/products/admin_product_form_view.dart';
import '../views/admin/users/admin_user_list_view.dart';
import '../views/admin/users/admin_user_form_view.dart';
import '../views/admin/entries/admin_entry_form_view.dart';
import '../views/admin/outputs/admin_output_form_view.dart';
import '../views/cashier/cashier_product_list_view.dart';
import '../views/cashier/cashier_output_form_view.dart';

class AppPages {
  AppPages._();

  static final pages = [
    /// Auth Routes
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),

    /// Admin Dashboard
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      transition: Transition.fadeIn,
    ),

    /// Cashier Dashboard
    GetPage(
      name: AppRoutes.cashierDashboard,
      page: () => const CashierDashboardView(),
      transition: Transition.fadeIn,
    ),

    /// Admin Product Routes
    GetPage(
      name: AppRoutes.adminProductList,
      page: () => const AdminProductListView(),
      binding: ProductBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminProductForm,
      page: () => const AdminProductFormView(),
      binding: ProductBinding(),
      transition: Transition.fadeIn,
    ),

    /// Admin User Routes
    GetPage(
      name: AppRoutes.adminUserList,
      page: () => const AdminUserListView(),
      binding: UserBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminUserForm,
      page: () => const AdminUserFormView(),
      binding: UserBinding(),
      transition: Transition.fadeIn,
    ),

    /// Admin Entry Routes
    GetPage(
      name: AppRoutes.adminEntryForm,
      page: () => const AdminEntryFormView(),
      binding: EntryBinding(),
      transition: Transition.fadeIn,
    ),

    /// Admin Output Routes
    GetPage(
      name: AppRoutes.adminOutputForm,
      page: () => const AdminOutputFormView(),
      binding: OutputBinding(),
      transition: Transition.fadeIn,
    ),

    /// Cashier Product Routes
    GetPage(
      name: AppRoutes.cashierProductList,
      page: () => const CashierProductListView(),
      binding: ProductBinding(),
      transition: Transition.fadeIn,
    ),

    /// Cashier Output Routes
    GetPage(
      name: AppRoutes.cashierOutputForm,
      page: () => const CashierOutputFormView(),
      binding: OutputBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
