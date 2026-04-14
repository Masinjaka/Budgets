import 'package:budgets/core/widgets/empty_state_phrase.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

export 'income_empty_state.dart';

/// Reusable empty state widget for transactions
class TransactionEmptyState extends StatelessWidget {
  final bool hasFilters;

  const TransactionEmptyState({
    super.key,
    required this.hasFilters,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStatePhrase(
      title: hasFilters
          ? 'Aucune dépense ne correspond'
          : 'Vos dépenses attendent',
      subtitle: hasFilters
          ? 'Essayez un autre mot-clé ou ajustez vos catégories.'
          : 'Ajoutez votre première dépense pour démarrer votre suivi.',
      icon: FontAwesomeIcons.receipt,
    );
  }
}
