import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'Gestion de Stock',
      description: 'Gerez vos produits facilement avec une interface claire.',
      icon: Icons.inventory_2_rounded,
      color: AppTheme.adminPrimary,
    ),
    OnboardingPage(
      title: 'Statistiques',
      description: 'Suivez vos stocks et vos ventes en temps reel.',
      icon: Icons.bar_chart_rounded,
      color: AppTheme.cashierPrimary,
    ),
    OnboardingPage(
      title: 'Controle Total',
      description: 'Gardez le controle de votre inventaire a tout moment.',
      icon: Icons.shield_rounded,
      color: Color(0xFFEA8E34),
    ),
  ];

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
    final width = Get.width;
    final horizontalPadding = (width * 0.06).clamp(16.0, 28.0);
    final maxWidth = math.min(width, 640.0);
    final activePage = _pages[_currentPage];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      activePage.color.withValues(alpha: 0.16),
                      const Color(0xFFF7F6FC),
                      const Color(0xFFEDEAF6),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      (Get.height * 0.012).clamp(8.0, 14.0),
                      horizontalPadding,
                      (Get.height * 0.02).clamp(12.0, 20.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _navigateToLogin,
                            child: Text(
                              'Passer',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF656D86),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _pages.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final page = _pages[index];
                              return _onboardingPage(page);
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => _pageIndicator(
                              isActive: index == _currentPage,
                              color: _pages[index].color,
                            ),
                          ),
                        ),
                        SizedBox(height: (Get.height * 0.018).clamp(10.0, 14.0)),
                        SizedBox(
                          height: (Get.height * 0.062).clamp(46.0, 54.0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  activePage.color,
                                  activePage.color.withValues(alpha: 0.82),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: AppTheme.glassShadow,
                            ),
                            child: ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                _currentPage == _pages.length - 1
                                    ? 'Commencer'
                                    : 'Suivant',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _onboardingPage(OnboardingPage page) {
    final bubbleSize = (Get.width * 0.36).clamp(120.0, 170.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: bubbleSize,
          height: bubbleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: page.color.withValues(alpha: 0.14),
            border: Border.all(
              color: page.color.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: AppTheme.glassShadow,
          ),
          child: Icon(
            page.icon,
            size: bubbleSize * 0.45,
            color: page.color,
          ),
        ),
        SizedBox(height: (Get.height * 0.03).clamp(16.0, 28.0)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: (Get.width * 0.08).clamp(26.0, 34.0),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF161E30),
            ),
          ),
        ),
        SizedBox(height: (Get.height * 0.015).clamp(10.0, 16.0)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: (Get.width * 0.05).clamp(12.0, 24.0)),
          child: Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: (Get.width * 0.043).clamp(14.0, 18.0),
              color: const Color(0xFF606884),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pageIndicator({required bool isActive, required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : const Color(0xFFC8CDDD),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class OnboardingPage {
  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}
