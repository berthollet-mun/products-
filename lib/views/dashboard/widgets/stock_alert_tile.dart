import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/theme/app_theme.dart';

class StockAlertTile extends StatelessWidget {
  const StockAlertTile({
    super.key,
    required this.productName,
    required this.quantity,
  });

  final String productName;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppTheme.glassCard(),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE9DB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFEA8E34),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              productName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF232A3A),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2E8),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Stock: $quantity',
              style: GoogleFonts.poppins(
                color: const Color(0xFFC56E1E),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
