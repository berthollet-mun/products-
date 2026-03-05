import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/theme/app_theme.dart';

class PageActionHeader extends StatelessWidget {
  const PageActionHeader({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
    this.isCashier = false,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool isCashier;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = (width * 0.05).clamp(18.0, 22.0);
    return Container(
      padding: EdgeInsets.all((width * 0.035).clamp(10.0, 12.0)),
      decoration: AppTheme.glassCard(),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF131A2A),
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: isCashier
                  ? AppTheme.cashierGradient
                  : AppTheme.adminGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.glassShadow,
            ),
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                buttonLabel,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchCardField extends StatelessWidget {
  const SearchCardField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassCard(),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF7A8197)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputRadius),
            borderSide: const BorderSide(color: Color(0xFFE9ECF4)),
          ),
          fillColor: AppTheme.inputFill,
          filled: true,
        ),
      ),
    );
  }
}

class GradientSubmitButton extends StatelessWidget {
  const GradientSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isCashier = false,
    this.icon = Icons.add_rounded,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isCashier;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = (MediaQuery.of(context).size.height * 0.07).clamp(
      44.0,
      50.0,
    );
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isCashier ? AppTheme.cashierGradient : AppTheme.adminGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.glassShadow,
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          label: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class CompactGradientFab extends StatelessWidget {
  const CompactGradientFab({
    super.key,
    required this.label,
    required this.onPressed,
    required this.heroTag,
    this.icon = Icons.add_rounded,
    this.isCashier = false,
  });

  final String label;
  final VoidCallback onPressed;
  final String heroTag;
  final IconData icon;
  final bool isCashier;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isCashier ? AppTheme.cashierGradient : AppTheme.adminGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: AppTheme.glassShadow,
          ),
          child: FloatingActionButton.extended(
            heroTag: heroTag,
            onPressed: onPressed,
            elevation: 0,
            highlightElevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            icon: Icon(icon, size: 18),
            label: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            extendedPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}
