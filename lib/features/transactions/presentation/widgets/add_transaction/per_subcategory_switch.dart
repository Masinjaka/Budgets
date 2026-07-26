import 'package:flutter/material.dart';

class PerSubcategorySwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const PerSubcategorySwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Par sous-catégorie',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
