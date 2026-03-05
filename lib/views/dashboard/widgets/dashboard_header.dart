import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final avatarSize = compact ? 46.0 : 54.0;
        final greetingSize = compact ? 12.0 : 14.0;
        final nameSize = compact ? 22.0 : 30.0;

        return Row(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(avatarSize / 2),
                image: const DecorationImage(
                  image: AssetImage('assets/images/img1.jpg'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: const Color(0xFFE3E4EC)),
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
            _action(Icons.notifications_none_rounded, compact: compact),
            SizedBox(width: compact ? 6 : 10),
            _action(Icons.menu_rounded, compact: compact),
          ],
        );
      },
    );
  }

  Widget _action(IconData icon, {required bool compact}) {
    return Container(
      width: compact ? 40 : 46,
      height: compact ? 40 : 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: const Color(0xFF3A4157),
        size: compact ? 20 : 24,
      ),
    );
  }
}
