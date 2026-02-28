import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/routes/app_pages.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/services/database_service.dart';
import 'package:product/views/user/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser le service de base de données
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      home: const LoginView(),
      getPages: AppPages.pages,
      initialRoute: AppRoutes.login,
    );
  }
}


