import 'package:flutter/material.dart';
import 'package:product/controllers/user_controller.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final UserController _userController = UserController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'caissier';

  // Ta couleur bleue fétiche
  final Color _primaryColor = const Color(0xFF1E3A8A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Widget réutilisable pour le style des champs (InputDecoration)
  InputDecoration _inputStyle(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white), // Toutes les icônes en BLANC
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05), // Fond sombre
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E0701), // Fond noir total
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E0701),
        elevation: 0,
        title: const Text(
          "Nouvel Utilisateur",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Créer un compte",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Remplissez les informations ci-dessous",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // CHAMP NOM
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Nom complet', Icons.person_outline),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Nom requis" : null,
                ),
                const SizedBox(height: 20),

                // CHAMP EMAIL
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputStyle('Email', Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email requis";
                    if (!v.contains('@')) return "Email invalide";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // CHAMP MOT DE PASSE
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle(
                    'Mot de passe',
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v != null && v.length < 6)
                      ? "Minimum 6 caractères"
                      : null,
                ),
                const SizedBox(height: 20),

                // SELECTEUR DE RÔLE (Dropdown)
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  dropdownColor: const Color(
                    0xFF1A1A1A,
                  ), // Fond du menu déroulant
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Rôle', Icons.verified_user_outlined),
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
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),

                const SizedBox(height: 40),

                // BOUTON ENREGISTRER
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _handleSave,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'ENREGISTRER',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final emailAvailable = await _userController.isEmailAvailable(
          _emailController.text.trim().toLowerCase(),
        );

        if (!emailAvailable) throw Exception('Cet email est déjà utilisé');

        await _userController.addUser(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
          name: _nameController.text.trim(),
        );

        if (mounted) {
          Navigator.pop(context, {
            'success': true,
            'message': 'Utilisateur créé avec succès',
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
