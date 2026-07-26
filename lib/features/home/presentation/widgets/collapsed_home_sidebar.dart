import 'package:flutter/material.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class CollapsedHomeSidebar extends StatelessWidget {
  const CollapsedHomeSidebar({
    required this.onExpand,
    required this.onEnvelopePressed,
    required this.onStatsPressed,
    required this.onPlanPressed,
    required this.onFeedbackPressed,
    required this.onSettingsPressed,
    super.key,
  });

  final VoidCallback onExpand;
  final VoidCallback onEnvelopePressed;
  final VoidCallback onStatsPressed;
  final VoidCallback onPlanPressed;
  final VoidCallback onFeedbackPressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            IconButton(
              key: const Key('persistent-sidebar-toggle'),
              onPressed: onExpand,
              tooltip: context.l10n.expandMenu,
              icon: const Icon(Icons.menu_rounded, size: 28),
            ),
            const Spacer(),
            _destination(
              context: context,
              icon: Icons.mail_outline_rounded,
              tooltip: context.l10n.envelope,
              onPressed: onEnvelopePressed,
            ),
            _destination(
              context: context,
              icon: Icons.pie_chart_outline_rounded,
              tooltip: context.l10n.stats,
              onPressed: onStatsPressed,
            ),
            // Plan is intentionally hidden until subscriptions are ready.
            // _destination(
            //   icon: Icons.workspace_premium_outlined,
            //   tooltip: 'Plan',
            //   onPressed: onPlanPressed,
            // ),
            _destination(
              context: context,
              icon: Icons.feedback_outlined,
              tooltip: context.l10n.feedback,
              onPressed: onFeedbackPressed,
            ),
            const SizedBox(height: 10),
            _destination(
              context: context,
              icon: Icons.settings_outlined,
              tooltip: context.l10n.settings,
              onPressed: onSettingsPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _destination({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        color: Theme.of(context).colorScheme.onSurface,
        icon: Icon(icon, size: 23),
      ),
    );
  }
}
