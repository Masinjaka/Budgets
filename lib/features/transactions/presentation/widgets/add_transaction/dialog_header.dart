import 'package:budgets/core/enums/transaction_type.dart';
import 'package:flutter/material.dart';

class DialogHeader extends StatelessWidget {
  final TransactionType type;
  final VoidCallback onClose;

  const DialogHeader({
    super.key,
    required this.type,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            type == TransactionType.income
                ? 'Nouveau revenu'
                : 'Nouvelle dépense',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
          ),
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}
