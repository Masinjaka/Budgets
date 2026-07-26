import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_wheel_picker.dart';
import 'package:budgets/features/notifications/domain/models/notification_settings.dart';
import 'package:budgets/features/notifications/domain/providers/pending_target_provider.dart';
import 'package:budgets/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:budgets/features/notifications/presentation/services/notification_permission_coordinator.dart';
import 'package:budgets/features/notifications/presentation/widgets/notification_reminder_time_tile.dart';
import 'package:budgets/features/notifications/presentation/widgets/notification_settings_toggle.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_menu_group.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_page_shell.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);
    final settings = state.asData?.value ??
        NotificationSettings.defaults(
          timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
        );
    final pending = ref.watch(pendingTargetProvider);
    return SettingsPageShell(
      title: context.l10n.notification,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
        children: [
          SettingsMenuGroup(
            items: [
              NotificationSettingsToggle(
                title: context.l10n.allowNotifications,
                icon: Icons.notifications_outlined,
                value: settings.notificationsEnabled,
                enabled: pending == null,
                onChanged: (value) => _setMaster(context, ref, value),
              ),
              if (settings.notificationsEnabled)
                NotificationSettingsToggle(
                  title: context.l10n.dailyReminders,
                  icon: Icons.alarm_outlined,
                  value: settings.remindersEnabled,
                  enabled: pending == null,
                  onChanged: (value) => _setReminder(context, ref, value),
                ),
              if (settings.notificationsEnabled && settings.remindersEnabled)
                NotificationReminderTimeTile(
                  time: TimeOfDay(
                    hour: settings.reminderHour,
                    minute: settings.reminderMinute,
                  ),
                  enabled: pending == null,
                  onTap: () => _selectReminderTime(context, ref, settings),
                ),
              if (settings.notificationsEnabled)
                NotificationSettingsToggle(
                  title: context.l10n.budgetAlerts,
                  icon: Icons.warning_amber_outlined,
                  value: settings.warningsEnabled,
                  enabled: pending == null,
                  onChanged: (value) => _setWarning(context, ref, value),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _setMaster(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    return _run(context, ref, ToggleTarget.master, enabled, () {
      return ref
          .read(notificationControllerProvider.notifier)
          .setAllEnabled(enabled);
    });
  }

  Future<bool> _setReminder(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    return _run(context, ref, ToggleTarget.reminders, enabled, () {
      return ref
          .read(notificationControllerProvider.notifier)
          .setRemindersEnabled(enabled);
    });
  }

  Future<bool> _setWarning(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    return _run(context, ref, ToggleTarget.warnings, enabled, () {
      return ref
          .read(notificationControllerProvider.notifier)
          .setWarningsEnabled(enabled);
    });
  }

  Future<void> _selectReminderTime(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final selected = await AppWheelPicker.time(
      context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
      title: context.l10n.selectReminderTime,
    );
    if (selected == null || !context.mounted) return;
    if (selected.hour == settings.reminderHour &&
        selected.minute == settings.reminderMinute) {
      return;
    }

    try {
      await _run(context, ref, ToggleTarget.reminderTime, false, () {
        return ref
            .read(notificationControllerProvider.notifier)
            .setReminderTime(hour: selected.hour, minute: selected.minute);
      });
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
    }
  }

  Future<bool> _run(
    BuildContext context,
    WidgetRef ref,
    ToggleTarget target,
    bool enabled,
    Future<bool> Function() update,
  ) async {
    if (ref.read(pendingTargetProvider) != null) return false;
    ref.read(pendingTargetProvider.notifier).set(target);
    try {
      if (enabled && !await NotificationPermissionCoordinator.ensure(context)) {
        return false;
      }
      return update();
    } finally {
      ref.read(pendingTargetProvider.notifier).set(null);
    }
  }
}
