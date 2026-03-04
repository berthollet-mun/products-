import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  // SUPPRESSION DU 'final' pour permettre la mise à jour
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Gestion de Stock',
      description:
          'Gérez facilement tous vos produits avec une interface intuitive et moderne',
      icon: Icons.inventory_2,
      color: Colors.blue,
    ),
    OnboardingPage(
      title: 'Statistiques',
      description:
          'Suivez vos stocks et analysez vos données avec des graphiques détaillés',
      icon: Icons.bar_chart,
      color: Colors.green,
    ),
    OnboardingPage(
      title: 'Contrôle Total',
      description:
          'Restez informé en temps réel et gardez le contrôle sur votre inventaire',
      icon: Icons.security,
      color: Colors.orange,
    ),
  ];

  final Color darkBlue = const Color(0xFF1E3A8A);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    // 1. On utilise AnnotatedRegion pour forcer les icônes en BLANC
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent, // Transparent pour voir l'image derrière
        statusBarIconBrightness: Brightness.light, // Icônes blanches (Android)
        statusBarBrightness: Brightness.dark, // Icônes blanches (iOS)
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1E0701),
        // 2. SUPPRESSION de l'AppBar (elle créait le conflit)
        body: Stack(
          children: [
            // GRADIENT BACKGROUND
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _pages[_currentPage].color.withValues(alpha: 0.3),
                      const Color(0xFF1E0701),
                      const Color(0xFF1E0701),
                    ],
                  ),
                ),
              ),
            ),

            // CONTENU
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, right: 16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _navigateToLogin,
                      child: const Text(
                        'Passer',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),
                            // LARGE ICON
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _pages[index].color.withValues(
                                  alpha: 0.2,
                                ),
                                border: Border.all(
                                  color: _pages[index].color.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _pages[index].icon,
                                size: 80,
                                color: _pages[index].color,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              _pages[index].title,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _pages[index].description,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(flex: 2),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildPageIndicator(
                      index == _currentPage,
                      _pages[index].color,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'COMMENCER'
                            : 'SUIVANT',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
