import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/bindings/auth_binding.dart';
import 'package:product/routes/app_pages.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/services/database_service.dart';
import 'package:product/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync<DatabaseService>(
    () => DatabaseService().init(),
    permanent: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion de Stock',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialBinding: AuthBinding(),
      getPages: AppPages.pages,
      initialRoute: AppRoutes.login,
    );
  }
}
