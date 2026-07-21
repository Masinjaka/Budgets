import 'package:budgets/features/plans/domain/models/plan_feature.dart';
import 'package:budgets/features/plans/presentation/widgets/plan_feature_row.dart';
import 'package:flutter/material.dart';

class PlanComparisonTable extends StatelessWidget {
  const PlanComparisonTable({required this.features, super.key});

  final List<PlanFeature> features;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'Feature',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Free',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Drala Plus',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFBEBEBE)),
        for (final feature in features) PlanFeatureRow(feature: feature),
      ],
    );
  }
}
