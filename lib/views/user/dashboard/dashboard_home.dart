import 'package:flutter/material.dart';
import 'package:product/utils/responsive_helper.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  // Couleur bleue identique à ton bouton de connexion
  final Color _primaryColor = const Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'TABLEAU DE BORD',
          style: TextStyle(
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, Admin 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isDesktop ? 8 : 5),
                Text(
                  'Voici l\'état actuel de votre inventaire.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                  ),
                ),
                SizedBox(height: isDesktop ? 40 : 30),

                // GRILLE DES 4 CARTES
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isDesktop ? 4 : 2,
                  crossAxisSpacing: isDesktop ? 20 : 15,
                  mainAxisSpacing: isDesktop ? 20 : 15,
                  childAspectRatio: isDesktop ? 1.3 : (isTablet ? 1.2 : 1.1),
                  children: [
                    _buildStatCard(
                      title: 'Produits',
                      value: '1,240',
                      icon: Icons.inventory_2_rounded,
                      color: _primaryColor,
                      context: context,
                    ),
                    _buildStatCard(
                      title: 'Utilisateurs',
                      value: '85',
                      icon: Icons.people_alt_rounded,
                      color: Colors.purple,
                      context: context,
                    ),
                    _buildStatCard(
                      title: 'Stock Faible',
                      value: '12',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.orange,
                      context: context,
                    ),
                    _buildStatCard(
                      title: 'Résultat',
                      value: '+24%',
                      icon: Icons.trending_up_rounded,
                      color: Colors.green,
                      context: context,
                    ),
                  ],
                ),

                SizedBox(height: isDesktop ? 40 : 30),

                // Section supplémentaire pour le look "Pro"
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isDesktop ? 24 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: isDesktop ? 28 : 24,
                      ),
                      SizedBox(width: isDesktop ? 20 : 15),
                      Expanded(
                        child: Text(
                          'Tout fonctionne normalement. Aucune erreur système détectée.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isDesktop ? 16 : (isTablet ? 15 : 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET POUR LES CARTES
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: isDesktop ? 36 : (isTablet ? 32 : 28),
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isDesktop ? 8 : 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white54,
              fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
            ),
          ),
        ],
      ),
    );
  }
}
