import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product/controllers/auth_controller.dart';
import 'package:product/utils/responsive_helper.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController authController = Get.put(AuthController());

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  final RxBool obscurePassword = true.obs;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (formKey.currentState!.validate()) {
      authController.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E0701),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 64 : (isTablet ? 48 : 30),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 500 : (isTablet ? 450 : double.infinity),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: isDesktop ? 60 : (isTablet ? 50 : 40),
                      color: Colors.white,
                    ),
                    SizedBox(height: isDesktop ? 16 : (isTablet ? 14 : 12)),
                    Text(
                      'Gestion de Stock',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 8 : (isTablet ? 6 : 6)),
                    Text(
                      'Connectez-vous',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : (isTablet ? 11 : 10),
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 28 : (isTablet ? 24 : 20)),

                    // EMAIL
                    TextFormField(
                      controller: emailController,
                      focusNode: emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 20 : 16,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 20 : 16,
                          ),
                          borderSide: const BorderSide(
                            color: Colors.white24,
                            width: 1,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 14 : (isTablet ? 12 : 10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email requis';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isDesktop ? 14 : (isTablet ? 12 : 10)),

                    // PASSWORD
                    Obx(
                      () => TextFormField(
                        controller: passwordController,
                        focusNode: passwordFocus,
                        obscureText: obscurePassword.value,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(color: Colors.white),
                        onFieldSubmitted: (_) => _submitLogin(),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              obscurePassword.value = !obscurePassword.value;
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              isDesktop ? 20 : 16,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              isDesktop ? 20 : 16,
                            ),
                            borderSide: const BorderSide(
                              color: Colors.white24,
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isDesktop ? 16 : (isTablet ? 14 : 12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mot de passe requis';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: isDesktop ? 28 : (isTablet ? 24 : 24)),

                    // BUTTON
                    Obx(
                      () => SizedBox(
                        height: isDesktop ? 52 : (isTablet ? 50 : 48),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isDesktop ? 20 : 16,
                              ),
                            ),
                          ),
                          onPressed: authController.isLoading.value
                              ? null
                              : _submitLogin,
                          child: authController.isLoading.value
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'SE CONNECTER',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
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
      ),
    );
  }
}
