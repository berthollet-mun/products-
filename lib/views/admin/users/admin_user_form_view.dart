import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/controllers/user_controller.dart';
import 'package:product/models/user.dart';
import 'package:product/theme/app_theme.dart';
import 'package:product/views/common/list_form_widgets.dart';
import 'package:product/views/common/role_guard.dart';

class AdminUserFormView extends StatefulWidget {
  const AdminUserFormView({super.key});

  @override
  State<AdminUserFormView> createState() => _AdminUserFormViewState();
}

class _AdminUserFormViewState extends State<AdminUserFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final User? _user;
  String _selectedRole = 'caissier';
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _user = Get.arguments as User?;
    _nameController = TextEditingController(text: _user?.name ?? '');
    _emailController = TextEditingController(text: _user?.email ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _selectedRole = _user?.role ?? 'caissier';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final maxWidth = math.min(width, 720.0);
    final horizontalPadding = (width * 0.05).clamp(14.0, 24.0);

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                (Get.height * 0.015).clamp(10.0, 18.0),
                horizontalPadding,
                (Get.height * 0.02).clamp(14.0, 24.0),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Container(
                    padding: EdgeInsets.all((width * 0.05).clamp(14.0, 22.0)),
                    decoration: AppTheme.glassCard(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _titleRow(),
                          const SizedBox(height: 20),
                          _field(
                            controller: _nameController,
                            hintText: 'Nom',
                            icon: Icons.person_rounded,
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Nom requis'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _field(
                            controller: _emailController,
                            hintText: 'Email',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email requis';
                              }
                              if (!value.contains('@')) {
                                return 'Email invalide';
                              }
                              return null;
                            },
                          ),
                          if (_user == null) ...[
                            const SizedBox(height: 20),
                            _field(
                              controller: _passwordController,
                              hintText: 'Mot de passe',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscure,
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFF707792),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Mot de passe requis';
                                }
                                if (value.length < 6) {
                                  return 'Minimum 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _field(
                              controller: _confirmPasswordController,
                              hintText: 'Confirmer mot de passe',
                              icon: Icons.lock_person_rounded,
                              obscureText: _obscure,
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Mots de passe differents';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRole,
                            decoration: const InputDecoration(
                              hintText: 'Role',
                              prefixIcon: Icon(
                                Icons.manage_accounts_rounded,
                                color: AppTheme.adminPrimary,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'admin', child: Text('Admin')),
                              DropdownMenuItem(value: 'caissier', child: Text('Caissier')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedRole = value);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          GradientSubmitButton(
                            label: _user == null ? 'Ajouter' : 'Mettre a jour',
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleRow() {
    return Row(
      children: [
        IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.adminDark),
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _user == null ? 'Ajouter Utilisateur' : 'Modifier Utilisateur',
              style: GoogleFonts.poppins(
                fontSize: (Get.width * 0.07).clamp(24.0, 32.0),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF151D2F),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppTheme.adminPrimary),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = Get.find<UserController>();
    if (_user == null) {
      final success = await controller.addUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        role: _selectedRole,
        name: _nameController.text.trim(),
      );
      if (success) {
        Get.back();
      }
      return;
    }

    final user = _user;
    final success = await controller.updateUser(
      id: user.id,
      updateData: {
        'email': _emailController.text.trim().toLowerCase(),
        'name': _nameController.text.trim(),
        'role': _selectedRole,
      },
    );
    if (success) {
      Get.back();
    }
  }
}
