import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product/views/sale/sale_view.dart';
import 'package:product/views/user/dashboard/dashboard_home_caissier.dart';
import 'package:product/views/user/profile_view.dart';

class DashboardCaissier extends StatefulWidget {
  const DashboardCaissier({super.key});

  @override
  State<DashboardCaissier> createState() => _DashboardCaissierState();
}

class _DashboardCaissierState extends State<DashboardCaissier> {
  int _currentIndex = 0;

  // Ta couleur bleue identique au bouton de login
  final Color _primaryColor = const Color(0xFF1E3A8A);

  // Pages pour le caissier
  final List<Widget> _caissierPages = [
    const DashboardHomeCaissier(), // Accueil caissier
    const SaleView(), // Ventes
    const ProfileView(), // Profil
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          SystemUiOverlayStyle.light, // Barre d'état (heure/batterie) en blanc
      child: Scaffold(
        backgroundColor: Colors.black, // Fond du Scaffold en noir

        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'DASHBOARD CAISSIER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white70),
              onPressed: () {
                // Logique de déconnexion ici
              },
            ),
          ],
        ),

        body: _caissierPages[_currentIndex],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),

          // --- CONFIGURATION DARK DESIGN ---
          backgroundColor: Colors.black, // Fond de la barre noir
          type: BottomNavigationBarType.fixed, // Bloque la couleur de fond
          selectedItemColor: _primaryColor, // Icône active en bleu
          unselectedItemColor:
              Colors.white, // Toutes les autres icônes en blanc pur
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0, // Enlève l'ombre grise

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_outlined),
              label: 'Ventes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
