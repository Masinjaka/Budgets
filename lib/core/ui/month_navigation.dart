import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthNavigation extends StatelessWidget {
  const MonthNavigation({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.canGoNext,
    super.key,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoNext;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = toBeginningOfSentenceCase(
      DateFormat('MMMM yyyy', locale).format(month),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(
          context: context,
          key: const Key('previous-month-button'),
          icon: Icons.chevron_left_rounded,
          onPressed: onPrevious,
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 82, maxWidth: 112),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppTypography.supporting,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _button(
          context: context,
          key: const Key('next-month-button'),
          icon: Icons.chevron_right_rounded,
          onPressed: canGoNext ? onNext : null,
        ),
      ],
    );
  }

  Widget _button({
    required BuildContext context,
    required Key key,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox.square(
      dimension: 32,
      child: IconButton(
        key: key,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).cardColor,
          disabledBackgroundColor: Theme.of(context).cardColor,
        ),
        icon: Icon(icon, size: 20),
      ),
    );
  }
}
