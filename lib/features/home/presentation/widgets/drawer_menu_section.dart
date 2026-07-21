import 'package:flutter/material.dart';

class DrawerMenuSection extends StatelessWidget {
  const DrawerMenuSection({
    required this.onEnvelopePressed,
    required this.onStatsPressed,
    required this.onPlanPressed,
    super.key,
  });

  final VoidCallback onEnvelopePressed;
  final VoidCallback onStatsPressed;
  final VoidCallback onPlanPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _item(
          Icons.mail_outline_rounded,
          'Envelope',
          key: const Key('drawer-envelope-button'),
          onTap: onEnvelopePressed,
        ),
        const SizedBox(height: 17),
        _item(
          Icons.pie_chart_outline_rounded,
          'Stats',
          key: const Key('drawer-stats-button'),
          onTap: onStatsPressed,
        ),
        const SizedBox(height: 17),
        _item(
          Icons.workspace_premium_outlined,
          'Plan',
          key: const Key('drawer-plan-button'),
          onTap: onPlanPressed,
        ),
      ],
    );
  }

  Widget _item(
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
              Icon(icon, size: 22, color: Colors.black),
              const SizedBox(width: 9),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
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
