import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color pageBackground = Color(0xFFEDEAF6);
  static const Color surface = Color(0xFFFFFFFF);
  static const double cardRadius = 28;
  static const double inputRadius = 15;
  static const Color adminPrimary = Color(0xFF2D79E6);
  static const Color adminDark = Color(0xFF0B47A1);
  static const Color cashierPrimary = Color(0xFF26A69A);
  static const Color cashierDark = Color(0xFF00695C);
  static const Color inputFill = Color(0xFFF6F7FB);

  static const LinearGradient adminGradient = LinearGradient(
    colors: [adminPrimary, adminDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cashierGradient = LinearGradient(
    colors: [cashierPrimary, cashierDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pageGradient = LinearGradient(
    colors: [Color(0xFFF5F3FB), Color(0xFFE8E5F2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static BoxDecoration glassCard({Gradient? gradient, Color? color}) {
    return BoxDecoration(
      gradient: gradient,
      color: gradient == null ? (color ?? surface) : null,
      borderRadius: BorderRadius.circular(cardRadius),
      boxShadow: glassShadow,
    );
  }

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.poppinsTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: pageBackground,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF161E30),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: Color(0xFFE8EBF4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: adminPrimary, width: 1.2),
        ),
      ),
    );
  }
}
