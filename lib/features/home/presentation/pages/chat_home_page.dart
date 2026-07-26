import 'dart:async';

import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/ai_entry/domain/repositories/ai_entry_repository.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/envelopes/domain/repositories/envelope_repository.dart';
import 'package:budgets/features/home/presentation/controllers/home_drawer_motion_controller.dart';
import 'package:budgets/features/home/presentation/widgets/chat_home_layout.dart';
import 'package:budgets/features/home/data/services/home_repository_factory.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_destination_navigator.dart';
import 'package:budgets/features/home/presentation/view_models/activity_calendar_view_model.dart';
import 'package:budgets/features/notifications/presentation/widgets/notification_permission_prompt.dart';
import 'package:budgets/features/notifications/data/repositories/finance_notification_repository_factory.dart';
import 'package:budgets/features/notifications/domain/repositories/finance_notification_repository.dart';
import 'package:budgets/features/notifications/presentation/view_models/finance_notification_view_model.dart';
import 'package:budgets/features/stats/domain/repositories/monthly_stats_repository.dart';
import 'package:budgets/features/receipts/domain/repositories/receipt_repository.dart';
import 'package:flutter/material.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({
    this.today,
    this.aiEntryRepository,
    this.envelopeRepository,
    this.statsRepository,
    this.receiptRepository,
    this.isSignedIn,
    this.currencyState,
    this.notificationRepository,
    super.key,
  });

  final DateTime? today;
  final AiEntryRepository? aiEntryRepository;
  final EnvelopeRepository? envelopeRepository;
  final MonthlyStatsRepository? statsRepository;
  final ReceiptRepository? receiptRepository;
  final bool Function()? isSignedIn;
  final CurrencyState? currencyState;
  final FinanceNotificationRepository? notificationRepository;

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>
    with SingleTickerProviderStateMixin {
  late final HomeDrawerMotionController _drawer;
  late final DateTime _today;
  late final AiEntryViewModel _aiEntryViewModel;
  late final ActivityCalendarViewModel _activityCalendarViewModel;
  late final FinanceNotificationViewModel _notificationViewModel;
  late DateTime _selectedDate;
  DateTime? _loadedDate;

  @override
  void initState() {
    super.initState();
    _drawer = HomeDrawerMotionController(this);
    _today = DateUtils.dateOnly(widget.today ?? DateTime.now());
    _selectedDate = _today;
    final defaults = HomeRepositoryFactory.create(_today);
    final repository = widget.aiEntryRepository ?? defaults.ai;
    _aiEntryViewModel = AiEntryViewModel(
      repository,
      _today,
      receiptRepository: widget.receiptRepository ?? defaults.receipts,
    );
    _activityCalendarViewModel = ActivityCalendarViewModel(repository);
    _notificationViewModel = FinanceNotificationViewModel(
      widget.notificationRepository ??
          FinanceNotificationRepositoryFactory.create(),
    );
    _aiEntryViewModel.addListener(_syncSelectedActivity);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadSelectedDate());
      unawaited(_activityCalendarViewModel.loadMonth(_today));
      unawaited(_refreshNotifications());
    });
  }

  Future<void> _loadSelectedDate() async {
    final targetDate = _selectedDate;
    try {
      await _aiEntryViewModel.loadDate(targetDate);
      if (_selectedDate != targetDate) return;
      _loadedDate = targetDate;
      _syncSelectedActivity();
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = DateUtils.dateOnly(date));
    _drawer.close();
    unawaited(_loadSelectedDate());
  }

  void _syncSelectedActivity() {
    if (_loadedDate != _selectedDate || _aiEntryViewModel.isLoading) {
      return;
    }
    _activityCalendarViewModel.setActivity(
      _selectedDate,
      _aiEntryViewModel.entries.isNotEmpty,
    );
  }

  void _resetAfterDataDeletion() {
    _activityCalendarViewModel.clear();
    _notificationViewModel.clear();
    unawaited(
      _aiEntryViewModel.resetAfterDataDeletion().catchError((Object error) {
        if (mounted) showErrorToast(context, error);
      }),
    );
  }

  Future<void> _refreshNotifications() async {
    try {
      await _notificationViewModel.load();
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  @override
  void dispose() {
    _aiEntryViewModel.removeListener(_syncSelectedActivity);
    _activityCalendarViewModel.dispose();
    _notificationViewModel.dispose();
    _aiEntryViewModel.dispose();
    _drawer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = DrawerDestinationNavigator(
      context: context,
      selectedDate: _selectedDate,
      closeDrawer: _drawer.close,
      onReturn: _aiEntryViewModel.refreshBalances,
      shouldRunOnReturn: widget.isSignedIn,
      envelopeRepository: widget.envelopeRepository,
      statsRepository: widget.statsRepository,
      onDataDeleted: _resetAfterDataDeletion,
      currencyState: widget.currencyState,
    );
    return NotificationPermissionPrompt(
      child: ChatHomeLayout(
        today: _today,
        selectedDate: _selectedDate,
        drawerController: _drawer.animation,
        viewModel: _aiEntryViewModel,
        activityCalendarViewModel: _activityCalendarViewModel,
        currencyState: widget.currencyState,
        onOpenDrawer: _drawer.open,
        onCloseDrawer: _drawer.close,
        onDateSelected: _selectDate,
        onEnvelopePressed: destinations.openEnvelopes,
        onStatsPressed: destinations.openStats,
        onPlanPressed: destinations.openPlans,
        onFeedbackPressed: destinations.openFeedback,
        notificationViewModel: _notificationViewModel,
        onNotificationsPressed: () => destinations.openNotifications(
          _notificationViewModel,
        ),
        onFinanceChanged: _refreshNotifications,
        onSettingsPressed: destinations.openSettings,
        onDragUpdate: _drawer.updateDrag,
        onDragEnd: _drawer.settle,
        onDragCancel: _drawer.cancelDrag,
      ),
    );
  }
}
