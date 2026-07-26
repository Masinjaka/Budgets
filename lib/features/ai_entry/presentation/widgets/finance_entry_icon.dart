import 'package:flutter/material.dart';

class FinanceEntryIcon extends StatelessWidget {
  const FinanceEntryIcon({
    required this.emoji,
    required this.iconKey,
    super.key,
  });

  final String emoji;
  final String iconKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _resolvedEmoji,
        key: const Key('finance-entry-emoji'),
        style: const TextStyle(fontSize: 22),
      ),
    );
  }

  String get _resolvedEmoji {
    if (emoji.trim().isNotEmpty) return emoji;
    return switch (iconKey) {
      'food' => '🍔',
      'shopping' => '🛒',
      'transport' => '🚗',
      'housing' => '🏠',
      'health' => '🩺',
      'entertainment' => '🎬',
      'education' => '🎓',
      'utilities' => '💡',
      'salary' => '💼',
      'freelance' => '💻',
      'income' => '💰',
      'transfer' => '🔄',
      _ => '🧾',
    };
  }
}
