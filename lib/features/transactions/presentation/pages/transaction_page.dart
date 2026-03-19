import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/presentation/pages/expense_tab_content.dart';
import 'package:budgets/features/transactions/presentation/pages/income_tab_content.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted || _currentTabIndex == _tabController.index) {
      return;
    }
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  void _openSearchPage() {
    final type = _currentTabIndex == 0 ? 'expense' : 'income';
    context.push('/transaction-search?type=$type');
  }

  void _openAddTransactionDialog() {
    final transactionType = _currentTabIndex == 0
        ? TransactionType.expense
        : TransactionType.income;
    AddTransactionDialog.show(
      context,
      transactionType: transactionType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: theme.scaffoldBackgroundColor,
          scrolledUnderElevation: 0,
          titleSpacing: 6.w,
          title: Text(
            'Transactions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 3.w),
              child: IconButton(
                tooltip: 'Rechercher',
                onPressed: _openSearchPage,
                icon: Icon(
                  Icons.search,
                  size: 21.sp,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(8.h),
            child: Padding(
              padding: EdgeInsets.fromLTRB(6.w, 0, 6.w, 1.h),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: EdgeInsets.all(1.w),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.tabBarTheme.indicatorColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: theme.tabBarTheme.labelColor,
                  unselectedLabelColor: theme.tabBarTheme.unselectedLabelColor?.withValues(alpha: 0.7),
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      return states.contains(WidgetState.focused)
                          ? null
                          : Colors.transparent;
                    },
                  ),
                  splashFactory: NoSplash.splashFactory,
                  labelStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Dépenses'),
                    Tab(text: 'Revenus'),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: 13.w,
          height: 13.w,
          child: FloatingActionButton(
            heroTag: 'transactionFab',
            onPressed: _openAddTransactionDialog,
            backgroundColor: Theme.of(context).primaryColor,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            TransactionTabContent(),
            IncomeTabContent(),
          ],
        ),
      ),
    );
  }
}
