import 'package:budgets/core/paths.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/onboarding/presentation/widgets/onboarding_image.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GettingStartedPage extends StatefulWidget {
  const GettingStartedPage({super.key});

  @override
  State<GettingStartedPage> createState() => _GettingStartedPageState();
}

class _GettingStartedPageState extends State<GettingStartedPage> {
  static const int _kInitialPage = 1000;
  final List<String> _images = const [
    AppPaths.onboarding1,
    AppPaths.onboarding2,
    AppPaths.onboarding3,
  ];

  final List<String> _texts = const [
    'Suivez vos dépenses et revenus.',
    'Atteignez vos objectifs financiers.',
    'Suivez vos abonnements facilement.',
  ];

  late final PageController _pageController =
      PageController(initialPage: _kInitialPage);
  int _currentPage = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _currentPage = _kInitialPage % _images.length;
    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index % _images.length;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imagePath = _images[index % _images.length];
                      return OnboardingImage(imagePath);
                    },
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppTheme.backgroundDark
                                  .withAlpha((1 * 255).round()),
                              AppTheme.backgroundDark
                                  .withAlpha((0.8 * 255).round()),
                              AppTheme.backgroundDark
                                  .withAlpha((0.6 * 255).round()),
                              AppTheme.backgroundDark
                                  .withAlpha((0.4 * 255).round()),
                              AppTheme.backgroundDark
                                  .withAlpha((0.2 * 255).round()),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            SmoothPageIndicator(
              controller: _pageController,
              count: _images.length,
              effect: ExpandingDotsEffect(
                dotHeight: 6,
                dotWidth: 6,
                spacing: 8,
                dotColor: Colors.grey.shade600,
                activeDotColor: AppTheme.primaryGreen,
                expansionFactor: 3.2,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(32, 16, 32, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Drala',
                        style: const TextStyle(
                          fontSize: AppTypography.title,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _texts[_currentPage],
                        key: ValueKey(_currentPage),
                        style: const TextStyle(
                          fontSize: AppTypography.body,
                        ),
                      )
                          .animate(key: ValueKey('text_$_currentPage'))
                          .fadeIn(duration: 450.ms, curve: Curves.easeOut)
                          .then() // keep chain explicit
                          .shake(duration: 0.ms) // no-op to satisfy lints
                      ,
                    ),
                    const Spacer(),
                    CustomButton(
                      text: 'Commencer',
                      onPressed: () => context.push('/signup'),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: Text.rich(
                        TextSpan(
                          text: 'J\'ai déjà un compte. ',
                          style: const TextStyle(
                            fontSize: AppTypography.body,
                          ),
                          children: [
                            TextSpan(
                              text: 'Se connecter',
                              style: TextStyle(
                                fontSize: AppTypography.body,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.push('/login');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
