import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/controllers/user_controller.dart';
import 'package:product/models/user.dart';
import 'package:product/views/common/role_guard.dart';

class AdminUserFormView extends StatefulWidget {
  const AdminUserFormView({super.key});

  @override
  State<AdminUserFormView> createState() => _AdminUserFormViewState();
}

class _AdminUserFormViewState extends State<AdminUserFormView> {
  final _formKey = GlobalKey<FormState>();
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
    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _user == null ? 'Ajouter un utilisateur' : 'Modifier utilisateur',
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Nom requis'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscure,
                    decoration: const InputDecoration(
                      labelText: 'Confirmer mot de passe',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Mots de passe differents';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(
                      value: 'caissier',
                      child: Text('Caissier'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(_user == null ? 'Creer' : 'Mettre a jour'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

    final success = await controller.updateUser(
      id: _user.id,
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
