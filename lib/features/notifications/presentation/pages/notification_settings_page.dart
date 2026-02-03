import 'package:budgets/core/ui/glass_flexible_space.dart';
import 'package:budgets/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_card.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_section.dart';
import 'package:budgets/features/notifications/domain/models/notification_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  _ToggleTarget? _pendingTarget;

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationControllerProvider);
    final settings = notificationsState.asData?.value ??
        NotificationSettings.defaults(
          timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
        );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassFlexibleSpace(),
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                _buildSettingsSection(context, ref, settings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    final enabled = settings.notificationsEnabled;
    final masterBusy = _pendingTarget == _ToggleTarget.master;
    final reminderBusy = _pendingTarget == _ToggleTarget.reminders;
    final warningBusy = _pendingTarget == _ToggleTarget.warnings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingSection(
          title: 'Préférences',
          children: [
            SizedBox(height: 1.h),
            SettingCard(
              title: 'Activer les notifications',
              iconData: Icons.notifications_outlined,
              useSwitch: true,
              switchValue: enabled,
              switchDisabled: masterBusy,
              onSwitchChanged: masterBusy
                  ? null
                  : (value) async {
                      await _handleMasterToggle(
                        context,
                        ref,
                        value,
                      );
                    },
              onTap: () {},
            ),
            if (enabled) ...[
              SizedBox(height: 1.h),
              SettingCard(
                title: 'Rappels quotidiens',
                iconData: Icons.alarm_outlined,
                useSwitch: true,
                switchValue: settings.remindersEnabled,
                switchDisabled: reminderBusy,
                onSwitchChanged: reminderBusy
                    ? null
                    : (value) async {
                        await _handleReminderToggle(
                          context,
                          ref,
                          value,
                        );
                      },
                onTap: () {},
              ),
              SizedBox(height: 1.h),
              SettingCard(
                title: 'Alertes de budget',
                iconData: Icons.warning_amber_outlined,
                useSwitch: true,
                switchValue: settings.warningsEnabled,
                switchDisabled: warningBusy,
                onSwitchChanged: warningBusy
                    ? null
                    : (value) async {
                        await _handleWarningToggle(
                          context,
                          ref,
                          value,
                        );
                      },
                onTap: () {},
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _handleMasterToggle(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (_pendingTarget != null) return;
    setState(() => _pendingTarget = _ToggleTarget.master);
    if (!enabled) {
      await ref
          .read(notificationControllerProvider.notifier)
          .setAllEnabled(false);
      if (mounted) {
        setState(() => _pendingTarget = null);
      }
      return;
    }

    final allowed = await _ensurePermission(context);
    if (!allowed) {
      if (mounted) {
        setState(() => _pendingTarget = null);
      }
      return;
    }

    await ref.read(notificationControllerProvider.notifier).setAllEnabled(true);
    if (mounted) {
      setState(() => _pendingTarget = null);
    }
  }

  Future<void> _handleReminderToggle(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (_pendingTarget != null) return;
    setState(() => _pendingTarget = _ToggleTarget.reminders);
    if (!enabled) {
      await ref
          .read(notificationControllerProvider.notifier)
          .setRemindersEnabled(false);
      if (mounted) {
        setState(() => _pendingTarget = null);
      }
      return;
    }

    final allowed = await _ensurePermission(context);
    if (!allowed) {
      if (mounted) {
        setState(() => _pendingTarget = null);
      }
      return;
    }

    await ref
        .read(notificationControllerProvider.notifier)
        .setRemindersEnabled(true);
    if (mounted) {
      setState(() => _pendingTarget = null);
    }
  }

  Future<void> _handleWarningToggle(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (_pendingTarget != null) return;
    setState(() => _pendingTarget = _ToggleTarget.warnings);
    if (!enabled) {
      await ref
          .read(notificationControllerProvider.notifier)
          .setWarningsEnabled(false);
      if (mounted) {
        setState(() => _pendingTarget = null);
      }
      return;
    }

    final allowed = await _ensurePermission(context);
    if (!allowed) {
      if (mounted) {
        setState(() => _pendingTarget = null);
      }
      return;
    }

    await ref
        .read(notificationControllerProvider.notifier)
        .setWarningsEnabled(true);
    if (mounted) {
      setState(() => _pendingTarget = null);
    }
  }

  Future<bool> _ensurePermission(BuildContext context) async {
    final permissionStatus = await Permission.notification.status;
    if (permissionStatus.isPermanentlyDenied ||
        permissionStatus.isRestricted) {
      if (!context.mounted) return false;
      await showDialog<void>(
        context: context,
        builder: (context) {
          return PermissionRequestDialog(
            title: 'Activer les notifications',
            message:
                'Vous avez bloqué les notifications. Ouvrez les réglages pour '
                'les autoriser.',
            allowText: 'Ouvrir les réglages',
            denyText: 'Annuler',
            onAllow: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            onDeny: () => Navigator.of(context).pop(),
          );
        },
      );
      return false;
    }

    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (_isAuthorized(settings.authorizationStatus)) {
      return true;
    }

    if (!context.mounted) return false;
    final allow = await showDialog<bool>(
      context: context,
      builder: (context) {
        return PermissionRequestDialog(
          title: 'Activer les notifications',
          message:
              'Autorisez les notifications pour recevoir vos rappels quotidiens '
              'et les alertes de budget.',
          allowText: 'Autoriser',
          denyText: 'Refuser',
          onAllow: () => Navigator.of(context).pop(true),
          onDeny: () => Navigator.of(context).pop(false),
        );
      },
    );

    return allow == true;
  }

  bool _isAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }
}

enum _ToggleTarget { master, reminders, warnings }
