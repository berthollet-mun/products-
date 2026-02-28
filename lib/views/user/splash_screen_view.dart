import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_view.dart';

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
      title: 'Gestion',
      description:
          'Gérez facilement tous vos produits avec une interface intuitive et moderne',
      imagePath: 'assets/images/img1.jpg',
    ),
    OnboardingPage(
      title: 'Statistiques',
      description:
          'Suivez vos stocks et analysez vos données avec des graphiques détaillés',
      imagePath: 'assets/images/img2.jpg',
    ),
    OnboardingPage(
      title: 'Contrôle',
      description:
          'Restez informé en temps réel et gardez le contrôle total sur votre inventaire',
      imagePath: 'assets/images/img3.jpg',
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
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
        backgroundColor: Colors.black,
        // 2. SUPPRESSION de l'AppBar (elle créait le conflit)
        body: Stack(
          children: [
            // IMAGE DE FOND
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey<int>(_currentPage),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_pages[_currentPage].imagePath),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(
                          alpha: 0.7,
                        ), // Important pour que le blanc des icônes ressorte
                        BlendMode.darken,
                      ),
                    ),
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
                            const Spacer(flex: 3),
                            Text(
                              _pages[index].title,
                              style: const TextStyle(
                                fontSize: 36,
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
                            const Spacer(flex: 1),
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
                    (index) => _buildPageIndicator(index == _currentPage),
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
                        backgroundColor: darkBlue,
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

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
