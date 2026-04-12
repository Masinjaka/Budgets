import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/navigation/domain/providers/sub_tab_providers.dart';
import 'package:budgets/features/planning/presentation/widgets/add_budget_bottom_sheet.dart';
import 'package:budgets/features/planning/presentation/widgets/add_goal_bottom_sheet.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction_dialog.dart';
import 'package:budgets/widgets/lottie_nav_icon.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NavigatorPage extends ConsumerStatefulWidget {
  const NavigatorPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends ConsumerState<NavigatorPage> {
  final List<ValueNotifier<int>> _tapNotifiers =
      List.generate(5, (_) => ValueNotifier<int>(0));
  bool _isNavBarVisible = true;
  ScrollDirection? _lastDirection;
  Timer? _scrollTimer;

  static const _tabs = [
    _TabConfig(
      label: 'Accueil',
      darkAsset: 'assets/lottie/dark/home.json',
      lightAsset: 'assets/lottie/light/home-light.json',
    ),
    _TabConfig(
      label: 'Transactions',
      darkAsset: 'assets/lottie/dark/transaction.json',
      lightAsset: 'assets/lottie/light/transaction-light.json',
    ),
    _TabConfig(
      label: 'Planifier',
      darkAsset: 'assets/lottie/dark/wallet.json',
      lightAsset: 'assets/lottie/light/wallet-light.json',
    ),
    _TabConfig(
      label: 'Rapports',
      darkAsset: 'assets/lottie/dark/pie.json',
      lightAsset: 'assets/lottie/light/pie-light.json',
    ),
    _TabConfig(
      label: 'Paramètres',
      darkAsset: 'assets/lottie/dark/setting.json',
      lightAsset: 'assets/lottie/light/setting-light.json',
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
    for (final notifier in _tapNotifiers) {
      notifier.dispose();
    }
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
            onPressed: (showFab && _isNavBarVisible) ? () => _onFabPressed(currentIndex) : null,
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
                  onTap: () {
                    _tapNotifiers[i].value++;
                    widget.navigationShell.goBranch(i);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: isActive ? 1.0 : 0.5,
                        child: LottieNavIcon(
                          darkAsset: tab.darkAsset,
                          lightAsset: tab.lightAsset,
                          isActive: isActive,
                          tapNotifier: _tapNotifiers[i],
                          size: 5.w,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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
    required this.darkAsset,
    required this.lightAsset,
  });

  final String label;
  final String darkAsset;
  final String lightAsset;
}
