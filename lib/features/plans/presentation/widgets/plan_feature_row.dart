import 'package:budgets/features/plans/domain/models/plan_feature.dart';
import 'package:flutter/material.dart';

class PlanFeatureRow extends StatelessWidget {
  const PlanFeatureRow({required this.feature, super.key});

  final PlanFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              feature.name,
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              feature.freeBenefit,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: .64),
                fontSize: 11.5,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              feature.plusBenefit,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
