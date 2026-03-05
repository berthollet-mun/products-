import 'package:flutter/material.dart';
import 'package:product/views/product/product_detail_view.dart';
import 'package:product/views/user/all_users/user_view.dart';
import 'package:product/views/user/dashboard/dashboard_home.dart';
import 'package:product/views/user/profile_view.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _currentIndex = 0;

  // Ta couleur bleue fétiche
  final Color _primaryColor = const Color(0xFF1E3A8A);

  final List<Widget> _adminPages = [
    const DashboardHome(),
    const ProductView(),
    UserView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // On met le fond du Scaffold parent en NOIR
      backgroundColor: const Color(0xFF1E0701),

      // Suppression de l'AppBar ici car elle est déjà définie dans DashboardHome
      // Si tu en veux une globale, utilise celle-ci :
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E0701),
        elevation: 0,
        title: const Text(
          'GESTION ADMIN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _adminPages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),

        // --- STYLE NOIR ET BLANC ---
        backgroundColor: const Color(0xFF1E0701), // Fond de la barre en noir
        type: BottomNavigationBarType.fixed, // Empêche le fond de devenir blanc
        selectedItemColor: _primaryColor, // Icône active en bleu
        unselectedItemColor: Colors.white54, // Icônes inactives en blanc cassé
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 10,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Style plus moderne
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
