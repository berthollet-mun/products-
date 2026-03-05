import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.name,
    required this.accentColor,
  });

  final String greeting;
  final String name;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final avatarSize = (width * 0.13).clamp(42.0, 56.0);
        final greetingSize = compact ? 12.0 : 14.0;
        final nameSize = (width * 0.07).clamp(22.0, 32.0);

        return Row(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(avatarSize / 2),
                border: Border.all(color: const Color(0xFFE3E4EC)),
                boxShadow: AppTheme.glassShadow,
              ),
              child: Icon(
                Icons.person_rounded,
                size: avatarSize * 0.58,
                color: const Color(0xFF7A8197),
              ),
            ),
            SizedBox(width: compact ? 8 : 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.poppins(
                      fontSize: greetingSize,
                      color: const Color(0xFF6C748C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: nameSize,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

}
