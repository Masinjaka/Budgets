import 'dart:async';

import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/notifications/data/datasources/notification_datasource.dart';
import 'package:budgets/features/notifications/presentation/services/notification_permission_service.dart';
import 'package:budgets/features/notifications/presentation/services/notification_service.dart';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPermissionPrompt extends StatefulWidget {
  const NotificationPermissionPrompt({required this.child, super.key});

  final Widget child;

  @override
  State<NotificationPermissionPrompt> createState() =>
      _NotificationPermissionPromptState();
}

class _NotificationPermissionPromptState
    extends State<NotificationPermissionPrompt> with WidgetsBindingObserver {
  NotificationService? _notificationService;
  bool _didPrompt = false;
  bool _waitingForSettings = false;

  NotificationPermissionService get _permissionService =>
      NotificationPermissionService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_promptIfNeeded());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_waitingForSettings) return;
    _waitingForSettings = false;
    unawaited(_registerAfterSettings());
  }

  Future<void> _promptIfNeeded() async {
    if (Firebase.apps.isEmpty) return;
    if (_didPrompt) return;
    _didPrompt = true;

    try {
      final dataSource = NotificationDataSource(Supabase.instance.client);
      final settings = await dataSource.fetchSettings();
      if (!settings.anyEnabled) return;
      _notificationService ??= NotificationService(dataSource);

      if (await _permissionService.isGranted()) {
        await _registerDevice();
        return;
      }

      final deviceStatus = await Permission.notification.status;
      if (deviceStatus.isPermanentlyDenied || deviceStatus.isRestricted) {
        await _showBlockedDialog();
        return;
      }

      if (!mounted || !await _showRequestDialog()) return;
      if (await _permissionService.request()) {
        await _registerDevice();
      }
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  Future<void> _registerDevice() async {
    await _notificationService?.registerDevice();
  }

  Future<void> _registerAfterSettings() async {
    try {
      if (await _permissionService.isGranted()) {
        await _registerDevice();
      }
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  Future<bool> _showRequestDialog() async {
    final result = await showAnimatedDialog<bool>(
      context: context,
      builder: (context) => PermissionRequestDialog(
        title: 'Activer les notifications',
        message: 'Autorisez les notifications pour recevoir vos rappels '
            'quotidiens et les alertes de budget.',
        allowText: 'Autoriser',
        denyText: 'Refuser',
        onAllow: () => Navigator.of(context).pop(true),
        onDeny: () => Navigator.of(context).pop(false),
      ),
    );
    return result == true;
  }

  Future<void> _showBlockedDialog() async {
    if (!mounted) return;
    await showAnimatedDialog<bool>(
      context: context,
      builder: (context) => PermissionRequestDialog(
        title: 'Notifications bloquées',
        message: 'Autorisez les notifications depuis les paramètres de votre '
            'appareil pour recevoir les rappels et alertes.',
        allowText: 'Ouvrir les paramètres',
        denyText: 'Annuler',
        onAllow: () async {
          _waitingForSettings = true;
          Navigator.of(context).pop(true);
          await openAppSettings();
        },
        onDeny: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
