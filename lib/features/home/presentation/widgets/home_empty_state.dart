import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/home/presentation/widgets/home_empty_prompt_card.dart';
import 'package:budgets/features/home/presentation/widgets/home_prompt_carousel.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({
    required this.isFirstEntryExperience,
    super.key,
  });

  final bool isFirstEntryExperience;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 310),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _title(context),
              const SizedBox(height: 24),
              if (isFirstEntryExperience)
                HomeEmptyPromptCard(
                  key: const Key('first-entry-prompt'),
                  height: 124,
                  emoji: '💰',
                  message: context.l10n.firstEntryIncomePrompt,
                )
              else
                const HomePromptCarousel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: AppTypography.headline,
          fontWeight: FontWeight.w800,
        );
    if (!isFirstEntryExperience) {
      return Text(context.l10n.emptyStateWelcomeBack, style: style);
    }
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: '${context.l10n.emptyStateWelcomeTo} '),
          const TextSpan(
            text: 'Drala',
            style: TextStyle(color: AppTheme.primaryGreen),
          ),
          const TextSpan(text: '!'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
