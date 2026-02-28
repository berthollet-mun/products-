import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/user.dart';
import '../../../utils/responsive_helper.dart';

class AdminUserFormView extends StatefulWidget {
  const AdminUserFormView({super.key});

  @override
  State<AdminUserFormView> createState() => _AdminUserFormViewState();
}

class _AdminUserFormViewState extends State<AdminUserFormView> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late String selectedRole;
  final formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  User? user;

  @override
  void initState() {
    super.initState();
    // Get user from arguments if editing
    user = Get.arguments as User?;
    nameController = TextEditingController(text: user?.name ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    selectedRole = user?.role ?? 'caissier';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Get.arguments == null
              ? 'Ajouter un utilisateur'
              : 'Modifier l\'utilisateur',
        ),
        backgroundColor: Colors.purple.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 16)),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 800 : (isTablet ? 600 : double.infinity),
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom complet',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 20 : 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom est requis';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      ),
                      prefixIcon: const Icon(Icons.email),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 20 : 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'email est requis';
                      }
                      if (!value.contains('@')) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                  if (user == null)
                    Column(
                      children: [
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                isDesktop ? 12 : 8,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(
                                  () => obscurePassword = !obscurePassword,
                                );
                              },
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 20 : 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le mot de passe est requis';
                            }
                            if (value.length < 6) {
                              return 'Au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                isDesktop ? 12 : 8,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 20 : 16,
                            ),
                          ),
                          validator: (value) {
                            if (value != passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                      ],
                    ),
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 16 : 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rôle',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isDesktop ? 18 : 16,
                          ),
                        ),
                        SizedBox(height: isDesktop ? 12 : 8),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Admin',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 14,
                                  ),
                                ),
                                leading: Radio<String>(
                                  value: 'admin',
                                  groupValue: selectedRole,
                                  onChanged: (value) {
                                    setState(() => selectedRole = value!);
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Caissier',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 14,
                                  ),
                                ),
                                leading: Radio<String>(
                                  value: 'caissier',
                                  groupValue: selectedRole,
                                  onChanged: (value) {
                                    setState(() => selectedRole = value!);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),
                  SizedBox(
                    width: double.infinity,
                    height: isDesktop ? 56 : (isTablet ? 52 : 48),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 12 : 8,
                          ),
                        ),
                      ),
                      onPressed: _handleSubmit,
                      child: Text(
                        user == null ? 'Créer l\'utilisateur' : 'Mettre à jour',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!formKey.currentState!.validate()) return;

    final controller = Get.find<UserController>();

    if (user == null) {
      // Create new user
      final success = await controller.addUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
        role: selectedRole,
        name: nameController.text.trim(),
      );

      if (success) {
        Get.back();
        Get.snackbar('Succès', 'Utilisateur créé');
      } else {
        Get.snackbar('Erreur', 'Impossible de créer l\'utilisateur');
      }
    } else {
      // Update existing user (only name and role)
      await controller.updateUser(
        id: user!.id,
        updateData: {
          'email': emailController.text.trim().toLowerCase(),
          'name': nameController.text.trim(),
          'role': selectedRole,
        },
      );
      Get.back();
      Get.snackbar('Succès', 'Utilisateur mis à jour');
    }
  }
}
