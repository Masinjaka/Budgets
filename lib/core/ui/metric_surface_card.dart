import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/core/ui/privacy_text.dart';
import 'package:flutter/material.dart';

class MetricSurfaceCard extends StatelessWidget {
  const MetricSurfaceCard({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.maskValue = true,
    this.height = 104,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool maskValue;
  final double height;

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      color: valueColor ?? Theme.of(context).colorScheme.onSurface,
      fontSize: AppTypography.body,
      fontWeight: FontWeight.w800,
    );
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon == null)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(dimension: 22),
            )
          else
            Icon(
              icon,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          const Spacer(),
          if (maskValue)
            PrivacyText(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            )
          else
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppTypography.caption,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
