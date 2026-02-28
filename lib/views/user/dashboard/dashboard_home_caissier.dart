import 'package:flutter/material.dart';
import 'package:product/utils/responsive_helper.dart';

class DashboardHomeCaissier extends StatelessWidget {
  const DashboardHomeCaissier({super.key});

  // Couleur bleue identique au login
  final Color _primaryColor = const Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E0701),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : (isTablet ? 32 : 25),
              vertical: isDesktop ? 32 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Caissier 📱',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 32 : (isTablet ? 28 : 26),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isDesktop ? 10 : 5),
                Text(
                  'Prêt pour une nouvelle vente ?',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                  ),
                ),
                SizedBox(height: isDesktop ? 40 : 30),

                // GRILLE DE RÉSUMÉ (2x2)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isDesktop ? 4 : 2,
                  crossAxisSpacing: isDesktop ? 20 : 15,
                  mainAxisSpacing: isDesktop ? 20 : 15,
                  childAspectRatio: isDesktop ? 1.3 : (isTablet ? 1.2 : 1.1),
                  children: [
                    _buildStatCard(
                      'Ventes Jour',
                      '24',
                      Icons.shopping_bag_outlined,
                      context,
                    ),
                    _buildStatCard(
                      'Total CA',
                      '450 \$',
                      Icons.payments_outlined,
                      context,
                    ),
                    _buildStatCard(
                      'Articles',
                      '112',
                      Icons.inventory_2_outlined,
                      context,
                    ),
                    _buildStatCard(
                      'Clients',
                      '18',
                      Icons.people_outline_rounded,
                      context,
                    ),
                  ],
                ),

                SizedBox(height: isDesktop ? 50 : 40),

                // GROS BOUTON D'ACTION POUR NOUVELLE VENTE
                GestureDetector(
                  onTap: () {
                    // Logique pour ouvrir la vue vente
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isDesktop ? 30 : 25),
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withValues(alpha: 0.3),
                          blurRadius: isDesktop ? 20 : 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_shopping_cart_rounded,
                          color: Colors.white,
                          size: isDesktop ? 32 : 28,
                        ),
                        SizedBox(width: isDesktop ? 20 : 15),
                        Text(
                          'NOUVELLE VENTE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isDesktop ? 40 : 30),

                // PETIT RAPPEL DE SÉCURITÉ
                Container(
                  padding: EdgeInsets.all(isDesktop ? 20 : 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white38,
                        size: isDesktop ? 24 : 20,
                      ),
                      SizedBox(width: isDesktop ? 15 : 10),
                      Expanded(
                        child: Text(
                          'Pensez à clôturer votre caisse ce soir.',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: isDesktop ? 16 : 12,
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

  // WIDGET DES CARTES (Icônes en blanc)
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isDesktop ? 40 : (isTablet ? 35 : 30),
          ),
          SizedBox(height: isDesktop ? 14 : 10),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white38,
              fontSize: isDesktop ? 16 : (isTablet ? 15 : 13),
            ),
          ),
        ],
      ),
    );
  }
}
