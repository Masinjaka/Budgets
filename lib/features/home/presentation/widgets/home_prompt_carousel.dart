import 'package:budgets/features/home/presentation/widgets/carousel_edge_fade.dart';
import 'package:budgets/features/home/presentation/widgets/home_empty_prompt_card.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePromptCarousel extends StatefulWidget {
  const HomePromptCarousel({super.key});

  @override
  State<HomePromptCarousel> createState() => _HomePromptCarouselState();
}

class _HomePromptCarouselState extends State<HomePromptCarousel> {
  static const _pageCount = 3;
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final prompts = [
      ('💰', context.l10n.emptyStateIncomePrompt),
      ('🛒', context.l10n.emptyStateExpensePrompt),
      ('🔄', context.l10n.emptyStateTransferPrompt),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            CarouselSlider.builder(
              key: const Key('home-prompt-carousel'),
              itemCount: prompts.length,
              itemBuilder: (context, index, _) {
                final prompt = prompts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: HomeEmptyPromptCard(
                    emoji: prompt.$1,
                    message: prompt.$2,
                  ),
                );
              },
              options: CarouselOptions(
                height: 130,
                viewportFraction: 0.86,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                enlargeFactor: 0.14,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 520),
                autoPlayCurve: Curves.easeInOutCubic,
                onPageChanged: (index, _) {
                  if (_activeIndex == index) return;
                  setState(() => _activeIndex = index);
                },
              ),
            ),
            const CarouselEdgeFade(
              key: Key('home-prompt-left-fade'),
              isLeft: true,
            ),
            const CarouselEdgeFade(
              key: Key('home-prompt-right-fade'),
              isLeft: false,
            ),
          ],
        ),
        const SizedBox(height: 14),
        AnimatedSmoothIndicator(
          key: const Key('home-prompt-indicator'),
          activeIndex: _activeIndex,
          count: _pageCount,
          effect: WormEffect(
            dotHeight: 6,
            dotWidth: 6,
            spacing: 6,
            dotColor:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.55),
            activeDotColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
