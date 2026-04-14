import 'dart:async';

import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/navigation/domain/providers/sub_tab_providers.dart';
import 'package:budgets/features/planning/presentation/widgets/add_budget_bottom_sheet.dart';
import 'package:budgets/features/planning/presentation/widgets/add_goal_bottom_sheet.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NavigatorPage extends ConsumerStatefulWidget {
  const NavigatorPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends ConsumerState<NavigatorPage> {
  bool _isNavBarVisible = true;
  ScrollDirection? _lastDirection;
  Timer? _scrollTimer;

  static const _tabs = [
    _TabConfig(
      label: 'Accueil',
      selectedIcon: FontAwesomeIcons.solidHouse,
      unselectedIcon: FontAwesomeIcons.house,
    ),
    _TabConfig(
      label: 'Transactions',
      selectedIcon: FontAwesomeIcons.solidCreditCard,
      unselectedIcon: FontAwesomeIcons.creditCard,
    ),
    _TabConfig(
      label: 'Planifier',
      selectedIcon: FontAwesomeIcons.solidCalendar,
      unselectedIcon: FontAwesomeIcons.calendar,
    ),
    _TabConfig(
      label: 'Profil',
      selectedIcon: FontAwesomeIcons.solidUser,
      unselectedIcon: FontAwesomeIcons.user,
    ),
  ];

  void _onFabPressed(int currentIndex) {
    if (currentIndex == 1) {
      final subTab = ref.read(transactionSubTabProvider);
      final type =
          subTab == 0 ? TransactionType.expense : TransactionType.income;
      AddTransactionDialog.show(context, transactionType: type);
    } else if (currentIndex == 2) {
      final subTab = ref.read(planningSubTabProvider);
      if (subTab == 0) {
        AddBudgetBottomSheet.show(context);
      } else {
        AddGoalBottomSheet.show(context);
      }
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final hintColor = Theme.of(context).hintColor;
    final showFab = currentIndex == 1 || currentIndex == 2;

    return Scaffold(
      extendBody: false,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          final direction = notification.direction;
          if (direction == ScrollDirection.idle) {
            _scrollTimer?.cancel();
            _lastDirection = null;
            return false;
          }
          if (direction == ScrollDirection.forward && !_isNavBarVisible) {
            _scrollTimer?.cancel();
            _lastDirection = null;
            setState(() => _isNavBarVisible = true);
          } else if (direction == ScrollDirection.reverse && _isNavBarVisible) {
            if (direction != _lastDirection) {
              _lastDirection = direction;
              _scrollTimer?.cancel();
              _scrollTimer = Timer(const Duration(milliseconds: 100), () {
                if (_isNavBarVisible) {
                  setState(() => _isNavBarVisible = false);
                }
              });
            }
          }
          return false;
        },
        child: widget.navigationShell,
      ),
      floatingActionButton: AnimatedScale(
        scale: (showFab && _isNavBarVisible) ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 13.w,
          height: 13.w,
          child: FloatingActionButton(
            onPressed: (showFab && _isNavBarVisible)
                ? () => _onFabPressed(currentIndex)
                : null,
            backgroundColor: Theme.of(context).primaryColor,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color.fromARGB(54, 48, 50, 55),
            ),
          ),
        ),
        padding: EdgeInsets.only(
          left: 3.w,
          right: 3.w,
          top: 1.2.h,
          bottom: MediaQuery.of(context).padding.bottom + 1.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final isActive = currentIndex == i;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.navigationShell.goBranch(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: FaIcon(
                        isActive ? tab.selectedIcon : tab.unselectedIcon,
                        key: ValueKey('${tab.label}-$isActive'),
                        size: 4.3.w,
                        color: isActive ? textColor : hintColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? textColor : hintColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TabConfig {
  const _TabConfig({
    required this.label,
    required this.selectedIcon,
    required this.unselectedIcon,
  });

  final String label;
  final FaIconData selectedIcon;
  final FaIconData unselectedIcon;
}
