import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/plans/domain/models/plan_tier.dart';
import 'package:budgets/features/plans/domain/plan_feature_catalog.dart';
import 'package:budgets/features/plans/presentation/widgets/plan_choice_card.dart';
import 'package:budgets/features/plans/presentation/widgets/plan_comparison_table.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({this.onSubscribePlus, super.key});

  final Future<void> Function()? onSubscribePlus;

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  PlanTier _selectedTier = PlanTier.free;
  bool _isSubmitting = false;

  Future<void> _continue() async {
    if (_selectedTier == PlanTier.free) {
      Navigator.of(context).pop();
      return;
    }
    final subscribe = widget.onSubscribePlus;
    if (subscribe == null) {
      showInfoToast(
        context,
        'Drala Plus checkout will be available once billing is configured.',
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await subscribe();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Plans',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose what works for you',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Stay on Free or unlock more ways to manage your money.',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .64),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        PlanChoiceCard(
                          title: 'Free',
                          subtitle: 'Your current plan',
                          icon: Icons.check_circle_outline_rounded,
                          isSelected: _selectedTier == PlanTier.free,
                          onTap: () =>
                              setState(() => _selectedTier = PlanTier.free),
                        ),
                        const SizedBox(width: 12),
                        PlanChoiceCard(
                          title: 'Drala Plus',
                          subtitle: 'More power and flexibility',
                          icon: Icons.auto_awesome_outlined,
                          isSelected: _selectedTier == PlanTier.plus,
                          onTap: () =>
                              setState(() => _selectedTier = PlanTier.plus),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const PlanComparisonTable(
                      features: PlanFeatureCatalog.features,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
              child: CustomButton(
                key: const Key('plan-continue-button'),
                text: _selectedTier == PlanTier.free
                    ? 'Stay on Free'
                    : 'Subscribe to Drala Plus',
                onPressed: _continue,
                isLoading: _isSubmitting,
                backgroundColor: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
