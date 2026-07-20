import 'dart:async';

import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/ai_entry/data/repositories/preview_ai_entry_repository.dart';
import 'package:budgets/features/ai_entry/data/repositories/supabase_ai_entry_repository.dart';
import 'package:budgets/features/ai_entry/data/services/ai_entry_service.dart';
import 'package:budgets/features/ai_entry/data/services/manual_entry_service.dart';
import 'package:budgets/features/ai_entry/domain/repositories/ai_entry_repository.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/envelopes/domain/repositories/envelope_repository.dart';
import 'package:budgets/features/home/presentation/widgets/chat_home_layout.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_destination_navigator.dart';
import 'package:budgets/features/home/presentation/view_models/activity_calendar_view_model.dart';
import 'package:budgets/features/stats/domain/repositories/monthly_stats_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({
    this.today,
    this.aiEntryRepository,
    this.envelopeRepository,
    this.statsRepository,
    super.key,
  });

  final DateTime? today;
  final AiEntryRepository? aiEntryRepository;
  final EnvelopeRepository? envelopeRepository;
  final MonthlyStatsRepository? statsRepository;

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 250);
  static const _flingVelocity = 500.0;
  late final AnimationController _drawerController;
  late final DateTime _today;
  late final AiEntryViewModel _aiEntryViewModel;
  late final ActivityCalendarViewModel _activityCalendarViewModel;
  late DateTime _selectedDate;
  DateTime? _loadedDate;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _today = DateUtils.dateOnly(widget.today ?? DateTime.now());
    _selectedDate = _today;
    final repository = widget.aiEntryRepository ?? _defaultRepository();
    _aiEntryViewModel = AiEntryViewModel(repository, _today);
    _activityCalendarViewModel = ActivityCalendarViewModel(repository);
    _aiEntryViewModel.addListener(_syncSelectedActivity);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadSelectedDate());
      unawaited(_activityCalendarViewModel.loadMonth(_today));
    });
  }

  AiEntryRepository _defaultRepository() {
    try {
      return SupabaseAiEntryRepository(
        AiEntryService(Supabase.instance.client),
        ManualEntryService(Supabase.instance.client),
      );
    } catch (_) {
      return PreviewAiEntryRepository(_today);
    }
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

  void _openDrawer() => _animateDrawerTo(1);

  void _closeDrawer() => _animateDrawerTo(0);

  void _animateDrawerTo(double target) {
    final distance = (target - _drawerController.value).abs();
    if (distance == 0) return;
    _drawerController.animateTo(
      target,
      duration: Duration(
        milliseconds: (_animationDuration.inMilliseconds * distance)
            .round()
            .clamp(1, _animationDuration.inMilliseconds),
      ),
      curve: Curves.easeOutCubic,
    );
  }

  void _updateDrawerDrag(DragUpdateDetails details, double drawerWidth) {
    _drawerController.value =
        (_drawerController.value + details.delta.dx / drawerWidth).clamp(0, 1);
  }

  void _settleDrawer(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final target = velocity.abs() >= _flingVelocity
        ? (velocity > 0 ? 1.0 : 0.0)
        : (_drawerController.value >= 0.5 ? 1.0 : 0.0);
    _animateDrawerTo(target);
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = DateUtils.dateOnly(date));
    _closeDrawer();
    unawaited(_loadSelectedDate());
  }

  void _syncSelectedActivity() {
    if (_loadedDate != _selectedDate ||
        _aiEntryViewModel.isLoading ||
        _aiEntryViewModel.entries.isEmpty) {
      return;
    }
    _activityCalendarViewModel.markActivity(_selectedDate);
  }

  @override
  void dispose() {
    _aiEntryViewModel.removeListener(_syncSelectedActivity);
    _activityCalendarViewModel.dispose();
    _aiEntryViewModel.dispose();
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = DrawerDestinationNavigator(
      context: context,
      selectedDate: _selectedDate,
      closeDrawer: _closeDrawer,
      onReturn: _aiEntryViewModel.refreshBalances,
      envelopeRepository: widget.envelopeRepository,
      statsRepository: widget.statsRepository,
    );
    return ChatHomeLayout(
      today: _today,
      selectedDate: _selectedDate,
      drawerController: _drawerController,
      viewModel: _aiEntryViewModel,
      activityCalendarViewModel: _activityCalendarViewModel,
      onOpenDrawer: _openDrawer,
      onCloseDrawer: _closeDrawer,
      onDateSelected: _selectDate,
      onEnvelopePressed: destinations.openEnvelopes,
      onStatsPressed: destinations.openStats,
      onPlanPressed: destinations.openPlans,
      onSettingsPressed: destinations.openSettings,
      onDragUpdate: _updateDrawerDrag,
      onDragEnd: _settleDrawer,
      onDragCancel: () => _animateDrawerTo(
        _drawerController.value >= 0.5 ? 1 : 0,
      ),
    );
  }
}
