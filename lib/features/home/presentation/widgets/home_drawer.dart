import 'package:budgets/features/home/presentation/widgets/drawer_wallet_section.dart';
import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_brand_header.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_menu_section.dart';
import 'package:budgets/features/home/presentation/widgets/resume_date_calendar.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/home/presentation/view_models/activity_calendar_view_model.dart';
import 'package:flutter/material.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    required this.width,
    required this.today,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onEnvelopePressed,
    required this.onStatsPressed,
    required this.onPlanPressed,
    required this.onFeedbackPressed,
    required this.onSettingsPressed,
    required this.viewModel,
    required this.activityCalendarViewModel,
    this.currencyState,
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
  final VoidCallback onFeedbackPressed;
  final Future<void> Function() onSettingsPressed;
  final AiEntryViewModel viewModel;
  final ActivityCalendarViewModel activityCalendarViewModel;
  final CurrencyState? currencyState;
  final VoidCallback? onCollapsePressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
                  tooltip: context.l10n.collapseMenu,
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
                      onFeedbackPressed: onFeedbackPressed,
                    ),
                    const SizedBox(height: 34),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        context.l10n.resumeFromDate,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: AppTypography.supporting,
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
                        currencyState: currencyState,
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
                    color: Theme.of(context).dividerColor,
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
