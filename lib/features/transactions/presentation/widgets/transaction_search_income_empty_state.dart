import 'package:budgets/core/widgets/empty_state_phrase.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionSearchIncomeEmptyState extends StatelessWidget {
  final bool hasFilters;

  const TransactionSearchIncomeEmptyState({
    super.key,
    required this.hasFilters,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStatePhrase(
      title: hasFilters
          ? 'Aucun revenu ne correspond'
          : 'Faites entrer vos revenus',
      subtitle: hasFilters
          ? 'Essayez un autre mot-clé ou ajustez vos catégories.'
          : 'Ajoutez votre premier revenu pour lancer votre suivi.',
      icon: FontAwesomeIcons.handHoldingDollar,
    );
  }
}
