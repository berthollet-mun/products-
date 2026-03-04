import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/bindings/auth_binding.dart';
import 'package:product/routes/app_pages.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/services/database_service.dart';

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

  static const Color backgroundColor = Color(0xFF1E0701);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion de Stock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.dark,
      initialBinding: AuthBinding(),
      getPages: AppPages.pages,
      initialRoute: AppRoutes.login,
    );
  }
}
