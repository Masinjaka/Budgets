import 'package:budgets/features/home/presentation/widgets/drawer_wallet_section.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_brand_header.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_menu_section.dart';
import 'package:budgets/features/home/presentation/widgets/resume_date_calendar.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/home/presentation/view_models/activity_calendar_view_model.dart';
import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    required this.width,
    required this.today,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onEnvelopePressed,
    required this.onStatsPressed,
    required this.onPlanPressed,
    required this.onSettingsPressed,
    required this.viewModel,
    required this.activityCalendarViewModel,
    this.onCollapsePressed,
    super.key,
  });

  final double width;
  final DateTime today;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onEnvelopePressed;
  final VoidCallback onStatsPressed;
  final VoidCallback onPlanPressed;
  final VoidCallback onSettingsPressed;
  final AiEntryViewModel viewModel;
  final ActivityCalendarViewModel activityCalendarViewModel;
  final VoidCallback? onCollapsePressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFFEFEFE),
        ),
        child: Stack(
          children: [
            if (onCollapsePressed != null)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  key: const Key('collapse-sidebar-button'),
                  onPressed: onCollapsePressed,
                  tooltip: 'Collapse menu',
                  icon: const Icon(Icons.chevron_left_rounded, size: 26),
                ),
              ),
            SafeArea(
              minimum: const EdgeInsets.only(top: 61, bottom: 39),
              child: SingleChildScrollView(
                key: const Key('drawer-scroll-view'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DrawerBrandHeader(
                      onProfilePressed: onSettingsPressed,
                    ),
                    const SizedBox(height: 27),
                    DrawerMenuSection(
                      onEnvelopePressed: onEnvelopePressed,
                      onStatsPressed: onStatsPressed,
                      onPlanPressed: onPlanPressed,
                    ),
                    const SizedBox(height: 34),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        'Resume from a specific date',
                        style: TextStyle(
                          color: Color(0xFF606060),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ListenableBuilder(
                      listenable: activityCalendarViewModel,
                      builder: (context, _) => ResumeDateCalendar(
                        today: today,
                        selectedDay: selectedDate,
                        activityDates: activityCalendarViewModel.activityDates,
                        onDaySelected: onDateSelected,
                        onVisibleMonthChanged:
                            activityCalendarViewModel.loadMonth,
                      ),
                    ),
                    const SizedBox(height: 22),
                    ListenableBuilder(
                      listenable: viewModel,
                      builder: (context, _) => DrawerWalletSection(
                        wallets: viewModel.wallets,
                        isAdding: viewModel.isAddingWallet,
                        onAddWallet: viewModel.addWallet,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: 1,
              child: IgnorePointer(
                child: DecoratedBox(
                  key: const Key('drawer-separator'),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9C9C9),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 4,
                        offset: Offset(-1, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
