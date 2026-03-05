import 'package:flutter/material.dart';

class AdminBottomNavigation extends StatelessWidget {
  const AdminBottomNavigation({
    super.key,
    required this.onAddTap,
    required this.onDashboardTap,
    required this.onProductsTap,
    required this.onOutputsTap,
    required this.onUsersTap,
  });

  final VoidCallback onAddTap;
  final VoidCallback onDashboardTap;
  final VoidCallback onProductsTap;
  final VoidCallback onOutputsTap;
  final VoidCallback onUsersTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navIcon(
                  icon: Icons.dashboard_outlined,
                  color: const Color(0xFF296FCF),
                  onTap: onDashboardTap,
                ),
                _navIcon(
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFF7B8296),
                  onTap: onProductsTap,
                ),
                const SizedBox(width: 56),
                _navIcon(
                  icon: Icons.outbox_rounded,
                  color: const Color(0xFF7B8296),
                  onTap: onOutputsTap,
                ),
                _navIcon(
                  icon: Icons.group_outlined,
                  color: const Color(0xFF7B8296),
                  onTap: onUsersTap,
                ),
              ],
            ),
          ),
          Positioned(
            top: -4,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: InkWell(
                    onTap: onAddTap,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xFF40C7BE),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(64, 199, 190, 0.35),
                            blurRadius: 22,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Icon(icon, color: color, size: 30),
        ),
      ),
    );
  }
}
