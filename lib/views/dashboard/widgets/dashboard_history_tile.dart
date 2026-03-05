import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardHistoryTile extends StatelessWidget {
  const DashboardHistoryTile({
    super.key,
    required this.productName,
    required this.timeLabel,
    required this.quantity,
    required this.isOutgoing,
  });

  final String productName;
  final String timeLabel;
  final int quantity;
  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
    final color = isOutgoing ? const Color(0xFFCF4C4C) : const Color(0xFF26A69A);
    final sign = isOutgoing ? '-' : '+';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '$sign$quantity',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              productName,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFF232A3A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            timeLabel,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF737A8F),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
