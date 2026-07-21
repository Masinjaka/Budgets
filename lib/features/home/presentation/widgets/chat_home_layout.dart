import 'package:budgets/core/layout/app_breakpoints.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/home/presentation/view_models/activity_calendar_view_model.dart';
import 'package:budgets/features/home/presentation/widgets/collapsed_home_sidebar.dart';
import 'package:budgets/features/home/presentation/widgets/home_dashboard.dart';
import 'package:budgets/features/home/presentation/widgets/home_drawer.dart';
import 'package:budgets/features/home/presentation/widgets/persistent_sidebar_layout.dart';
import 'package:budgets/features/home/presentation/widgets/sliding_drawer_layout.dart';
import 'package:flutter/material.dart';

class ChatHomeLayout extends StatelessWidget {
  const ChatHomeLayout({
    required this.today,
    required this.selectedDate,
    required this.drawerController,
    required this.viewModel,
    required this.activityCalendarViewModel,
    required this.onOpenDrawer,
    required this.onCloseDrawer,
    required this.onDateSelected,
    required this.onEnvelopePressed,
    required this.onStatsPressed,
    required this.onPlanPressed,
    required this.onSettingsPressed,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    super.key,
  });

  final DateTime today;
  final DateTime selectedDate;
  final AnimationController drawerController;
  final AiEntryViewModel viewModel;
  final ActivityCalendarViewModel activityCalendarViewModel;
  final VoidCallback onOpenDrawer;
  final VoidCallback onCloseDrawer;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onEnvelopePressed;
  final VoidCallback onStatsPressed;
  final VoidCallback onPlanPressed;
  final VoidCallback onSettingsPressed;
  final void Function(DragUpdateDetails, double) onDragUpdate;
  final ValueChanged<DragEndDetails> onDragEnd;
  final VoidCallback onDragCancel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final persistent = AppBreakpoints.usesPersistentNavigation(width);
          final drawerWidth = persistent
              ? AppBreakpoints.sidebarWidth(width)
              : AppBreakpoints.mobileDrawerWidth(width);
          final home = HomeDashboard(
            today: today,
            drawerProgress: drawerController,
            onMenuPressed: onOpenDrawer,
            viewModel: viewModel,
          );
          final drawer = HomeDrawer(
            width: drawerWidth,
            today: today,
            selectedDate: selectedDate,
            onDateSelected: onDateSelected,
            onEnvelopePressed: onEnvelopePressed,
            onStatsPressed: onStatsPressed,
            onPlanPressed: onPlanPressed,
            onSettingsPressed: onSettingsPressed,
            viewModel: viewModel,
            activityCalendarViewModel: activityCalendarViewModel,
            onCollapsePressed: persistent ? onCloseDrawer : null,
          );
          if (persistent) {
            return PersistentSidebarLayout(
              controller: drawerController,
              expandedWidth: drawerWidth,
              collapsedWidth: AppBreakpoints.collapsedSidebarWidth,
              expandedSidebar: drawer,
              collapsedSidebar: CollapsedHomeSidebar(
                onExpand: onOpenDrawer,
                onEnvelopePressed: onEnvelopePressed,
                onStatsPressed: onStatsPressed,
                onPlanPressed: onPlanPressed,
                onSettingsPressed: onSettingsPressed,
              ),
              home: home,
            );
          }
          return SlidingDrawerLayout(
            controller: drawerController,
            drawerWidth: drawerWidth,
            maximumDimming: 0.09,
            onDragUpdate: (details) => onDragUpdate(details, drawerWidth),
            onDragEnd: onDragEnd,
            onDragCancel: onDragCancel,
            drawer: drawer,
            home: home,
          );
        },
      ),
    );
  }
}
