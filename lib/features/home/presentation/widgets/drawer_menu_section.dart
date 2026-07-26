import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class DrawerMenuSection extends StatelessWidget {
  const DrawerMenuSection({
    required this.onEnvelopePressed,
    required this.onStatsPressed,
    required this.onPlanPressed,
    required this.onFeedbackPressed,
    super.key,
  });

  final VoidCallback onEnvelopePressed;
  final VoidCallback onStatsPressed;
  final VoidCallback onPlanPressed;
  final VoidCallback onFeedbackPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _item(
          context,
          Icons.mail_outline_rounded,
          context.l10n.envelope,
          key: const Key('drawer-envelope-button'),
          onTap: onEnvelopePressed,
        ),
        const SizedBox(height: 17),
        _item(
          context,
          Icons.pie_chart_outline_rounded,
          context.l10n.stats,
          key: const Key('drawer-stats-button'),
          onTap: onStatsPressed,
        ),
        // Plan is intentionally hidden until subscriptions are ready.
        // const SizedBox(height: 17),
        // _item(
        //   Icons.workspace_premium_outlined,
        //   'Plan',
        //   key: const Key('drawer-plan-button'),
        //   onTap: onPlanPressed,
        // ),
        const SizedBox(height: 17),
        _item(
          context,
          Icons.feedback_outlined,
          context.l10n.feedback,
          key: const Key('drawer-feedback-button'),
          onTap: onFeedbackPressed,
        ),
      ],
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label, {
    required Key key,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: 28,
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 9),
              Text(
                label,
                style: const TextStyle(
                  fontSize: AppTypography.body,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
