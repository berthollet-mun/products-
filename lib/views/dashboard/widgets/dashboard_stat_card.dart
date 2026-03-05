import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/theme/app_theme.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 160;
        final iconBox = compact ? 30.0 : 34.0;
        final valueSize = compact ? 22.0 : 30.0;
        final titleSize = compact ? 13.0 : 16.0;

        return Container(
          padding: EdgeInsets.all(compact ? 12 : 16),
          decoration: AppTheme.glassCard(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: compact ? 17 : 20),
              ),
              SizedBox(height: compact ? 8 : 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF131A2A),
                  ),
                ),
              ),
              SizedBox(height: compact ? 2 : 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF232A3A),
                    height: 1.1,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: compact ? 11 : 12,
                      color: const Color(0xFF7A8093),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
