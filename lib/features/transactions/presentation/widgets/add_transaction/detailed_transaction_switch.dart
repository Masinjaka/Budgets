import 'package:flutter/material.dart';

class DetailedTransactionSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const DetailedTransactionSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction détaillée',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                'Activer pour répartir le montant entre plusieurs sous-catégories',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          // activeThumbColor: Colors.white,
          activeTrackColor: Theme.of(context).primaryColor,
          inactiveThumbColor: Theme.of(context).colorScheme.tertiary,
          inactiveTrackColor: Theme.of(context).colorScheme.surfaceDim,
          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return null; // No outline when active
            }
            return Theme.of(context)
                .colorScheme
                .tertiary; // Match inactive thumb color
          }),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
