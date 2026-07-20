import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';

class CollapsedHomeSidebar extends StatelessWidget {
  const CollapsedHomeSidebar({
    required this.onExpand,
    required this.onEnvelopePressed,
    required this.onStatsPressed,
    required this.onPlanPressed,
    required this.onSettingsPressed,
    super.key,
  });

  final VoidCallback onExpand;
  final VoidCallback onEnvelopePressed;
  final VoidCallback onStatsPressed;
  final VoidCallback onPlanPressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFEFEFE),
        border: Border(right: BorderSide(color: Color(0xFFC9C9C9))),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            IconButton(
              key: const Key('persistent-sidebar-toggle'),
              onPressed: onExpand,
              tooltip: 'Expand menu',
              icon: const Icon(Icons.menu_rounded, size: 28),
            ),
            const Spacer(),
            _destination(
              icon: Icons.mail_outline_rounded,
              tooltip: 'Envelope',
              onPressed: onEnvelopePressed,
            ),
            _destination(
              icon: Icons.pie_chart_outline_rounded,
              tooltip: 'Stats',
              onPressed: onStatsPressed,
            ),
            _destination(
              icon: Icons.workspace_premium_outlined,
              tooltip: 'Plan',
              onPressed: onPlanPressed,
            ),
            const SizedBox(height: 10),
            _destination(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onPressed: onSettingsPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _destination({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        color: AppTheme.interactiveTextColor,
        icon: Icon(icon, size: 23),
      ),
    );
  }
}
