import 'package:budgets/features/home/presentation/widgets/drawer_wallet_section.dart';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              activityDates:
                                  activityCalendarViewModel.activityDates,
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
                        ],
                      ),
                    ),
                  ),
                  _menuRow(
                    Icons.mail_outline_rounded,
                    'Envelope',
                    key: const Key('drawer-envelope-button'),
                    onTap: onEnvelopePressed,
                  ),
                  const SizedBox(height: 11),
                  _menuRow(
                    Icons.pie_chart_outline_rounded,
                    'Stats',
                    key: const Key('drawer-stats-button'),
                    onTap: onStatsPressed,
                  ),
                  const SizedBox(height: 11),
                  _menuRow(
                    Icons.workspace_premium_outlined,
                    'Plan',
                    key: const Key('drawer-plan-button'),
                    onTap: onPlanPressed,
                  ),
                  const SizedBox(height: 11),
                  _menuRow(
                    Icons.settings_outlined,
                    'Settings',
                    key: const Key('drawer-settings-button'),
                    onTap: onSettingsPressed,
                  ),
                ],
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

  Widget _menuRow(
    IconData icon,
    String label, {
    Key? key,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: 25,
          child: Row(
            children: [
              Icon(icon, size: 22, color: Colors.black),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
