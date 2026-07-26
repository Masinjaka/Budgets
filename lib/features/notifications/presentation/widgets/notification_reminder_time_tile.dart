import 'package:budgets/features/settings/presentation/widgets/settings_choice_tile.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class NotificationReminderTimeTile extends StatelessWidget {
  const NotificationReminderTimeTile({
    required this.time,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  final TimeOfDay time;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SettingsChoiceTile(
      title: context.l10n.preferredReminderTime,
      subtitle: context.l10n.reminderDeliveryTime,
      leading: const Icon(Icons.schedule_outlined, size: 20),
      trailing: Text(
        key: const Key('notification-reminder-time-value'),
        MaterialLocalizations.of(context).formatTimeOfDay(
          time,
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        ),
        style: TextStyle(
          color: Theme.of(context).colorScheme.inverseSurface,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
