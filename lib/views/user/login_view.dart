import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/controllers/auth_controller.dart';
import 'package:product/theme/app_theme.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController authController = Get.find<AuthController>();

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
    final width = Get.width;
    final isCompact = width < 360;
    final bodyWidth = math.min(width, 560.0);
    final horizontalPadding = (width * 0.06).clamp(16.0, 36.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: (Get.height * 0.02).clamp(12.0, 24.0),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: bodyWidth),
                child: Container(
                  padding: EdgeInsets.all((width * 0.055).clamp(16.0, 28.0)),
                  decoration: AppTheme.glassCard(),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ✅ HEADER CENTRÉ
                        _header(isCompact),

                        SizedBox(
                          height: (Get.height * 0.028).clamp(18.0, 28.0),
                        ),

                        _textField(
                          controller: emailController,
                          focusNode: emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          hint: 'Email',
                          icon: Icons.mail_outline_rounded,
                          iconColor: const Color(0xFF2B9FAF),
                          onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Identifiant requis';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: (Get.height * 0.012).clamp(8.0, 12.0)),

                        Obx(
                          () => _textField(
                            controller: passwordController,
                            focusNode: passwordFocus,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            hint: 'Mot de passe',
                            icon: Icons.lock_outline_rounded,
                            iconColor: const Color(0xFF3D8DF3),
                            obscureText: obscurePassword.value,
                            onFieldSubmitted: (_) => _submitLogin(),
                            suffix: IconButton(
                              onPressed: () {
                                obscurePassword.value = !obscurePassword.value;
                              },
                              icon: Icon(
                                obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF6E7691),
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

                        SizedBox(
                          height: (Get.height * 0.025).clamp(16.0, 22.0),
                        ),

                        Obx(
                          () => SizedBox(
                            height: (Get.height * 0.07).clamp(48.0, 56.0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppTheme.cashierGradient,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: AppTheme.glassShadow,
                              ),
                              child: ElevatedButton(
                                onPressed: authController.isLoading.value
                                    ? null
                                    : _submitLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: authController.isLoading.value
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Se connecter',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: isCompact ? 16 : 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
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
        ),
      ),
    );
  }

  // ✅ TITRE "Connexion" EXACTEMENT AU MILIEU (Stack pro)
  Widget _header(bool isCompact) {
    final titleSize = isCompact ? 28.0 : 34.0;

    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Connexion',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF181F31),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required String? Function(String?) validator,
    void Function(String)? onFieldSubmitted,
    Widget? suffix,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: GoogleFonts.poppins(
        color: const Color(0xFF1D2436),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: const Color(0xFF8A91A8)),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 10, right: 8),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ),
        suffixIcon: suffix,
        prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 42),
      ),
      validator: validator,
    );
  }
}