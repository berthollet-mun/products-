import 'package:flutter/material.dart';
import 'package:product/controllers/user_controller.dart';
import 'package:product/utils/responsive_helper.dart';

class EditUserForm extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditUserForm({super.key, required this.userData});

  @override
  State<EditUserForm> createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final UserController _userController = UserController();

  bool _isLoading = false;
  String? _selectedRole;
  bool _changePassword = false;

  final Color _primaryColor = const Color(0xFF1E3A8A);

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.userData['email'] ?? '';
    _nameController.text = widget.userData['name'] ?? '';
    _selectedRole = widget.userData['role'];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Style des champs de saisie
  InputDecoration _inputStyle(String label, IconData icon) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white70,
        fontSize: isDesktop ? 16 : 14,
      ),
      prefixIcon: Icon(icon, color: Colors.white, size: isDesktop ? 24 : 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: isDesktop ? 16 : 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Modifier le profil",
          style: TextStyle(color: Colors.white, fontSize: isDesktop ? 24 : 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 600 : (isTablet ? 500 : double.infinity),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputStyle('Email', Icons.email_outlined),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Email requis" : null,
                    ),
                    SizedBox(height: isDesktop ? 24 : 16),

                    // NOM COMPLET
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputStyle(
                        'Nom complet',
                        Icons.person_outline,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Nom requis" : null,
                    ),
                    SizedBox(height: isDesktop ? 24 : 16),

                    // RÔLE
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      dropdownColor: const Color(0xFF1A1A1A),
                      icon: const Icon(
                        Icons.expand_more_rounded,
                        color: Colors.white70,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      isExpanded: true,
                      decoration: _inputStyle(
                        'Rôle',
                        Icons.verified_user_outlined,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Administrateur'),
                        ),
                        DropdownMenuItem(
                          value: 'caissier',
                          child: Text('Caissier'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedRole = v),
                      validator: (v) => v == null ? "Rôle requis" : null,
                    ),

                    SizedBox(height: isDesktop ? 32 : 24),

                    // SECTION MOT DE PASSE
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(
                          isDesktop ? 16 : 12,
                        ),
                      ),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: Text(
                              'Changer le mot de passe',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isDesktop ? 15 : 13,
                              ),
                            ),
                            value: _changePassword,
                            activeColor: _primaryColor,
                            onChanged: (val) => setState(() {
                              _changePassword = val ?? false;
                              if (!_changePassword) _passwordController.clear();
                            }),
                          ),
                          if (_changePassword)
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                isDesktop ? 16 : 12,
                                0,
                                isDesktop ? 16 : 12,
                                isDesktop ? 16 : 12,
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputStyle(
                                  'Nouveau mot de passe',
                                  Icons.lock_reset,
                                ),
                                validator: (v) =>
                                    (_changePassword &&
                                        (v == null || v.length < 6))
                                    ? "6 car. min"
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: isDesktop ? 48 : 40),

                    // BOUTONS
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'ANNULER',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: isDesktop ? 16 : 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isDesktop ? 16 : 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              padding: EdgeInsets.symmetric(
                                vertical: isDesktop ? 18 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  isDesktop ? 16 : 12,
                                ),
                              ),
                            ),
                            onPressed: _isLoading ? null : _updateUser,
                            child: _isLoading
                                ? SizedBox(
                                    height: isDesktop ? 24 : 20,
                                    width: isDesktop ? 24 : 20,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'METTRE À JOUR',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: isDesktop ? 18 : 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        Map<String, dynamic> updateData = {
          'email': _emailController.text.trim().toLowerCase(),
          'name': _nameController.text.trim(),
          'role': _selectedRole!,
        };
        if (_changePassword && _passwordController.text.isNotEmpty) {
          updateData['password'] = _passwordController.text;
        }
        await _userController.updateUser(
          id: widget.userData['id'],
          updateData: updateData,
        );
        if (mounted) {
          Navigator.pop(context, {
            'success': true,
            'message': 'Utilisateur modifié',
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
