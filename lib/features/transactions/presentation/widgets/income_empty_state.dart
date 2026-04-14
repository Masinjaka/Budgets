import 'package:budgets/core/widgets/empty_state_phrase.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IncomeEmptyState extends StatelessWidget {
  const IncomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStatePhrase(
      title: 'Faites entrer vos revenus',
      subtitle: 'Ajoutez votre premier revenu pour voir vos progrès.',
      icon: FontAwesomeIcons.handHoldingDollar,
    );
  }
}
