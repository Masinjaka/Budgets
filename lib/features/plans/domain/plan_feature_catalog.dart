import 'package:budgets/features/plans/domain/models/plan_feature.dart';

abstract final class PlanFeatureCatalog {
  static const features = [
    PlanFeature(
      name: 'Manual transactions',
      freeBenefit: 'Unlimited',
      plusBenefit: 'Unlimited',
    ),
    PlanFeature(
      name: 'AI transaction entry',
      freeBenefit: '20/day',
      plusBenefit: 'Generous monthly fair use',
    ),
    PlanFeature(
      name: 'Budgets',
      freeBenefit: 'Basic',
      plusBenefit: 'Advanced',
    ),
    PlanFeature(
      name: 'Reports',
      freeBenefit: 'Basic',
      plusBenefit: 'Advanced comparisons',
    ),
    PlanFeature(
      name: 'Cloud backup',
      freeBenefit: 'Limited or included',
      plusBenefit: 'Included',
    ),
    PlanFeature(
      name: 'Export',
      freeBenefit: 'Limited',
      plusBenefit: 'Included',
    ),
    PlanFeature(
      name: 'Receipt scanning',
      freeBenefit: 'No',
      plusBenefit: 'Included',
    ),
    PlanFeature(
      name: 'Multiple wallets',
      freeBenefit: 'Limited',
      plusBenefit: 'Included',
    ),
    PlanFeature(
      name: 'AI spending insights',
      freeBenefit: 'No',
      plusBenefit: 'Included',
    ),
  ];
}
