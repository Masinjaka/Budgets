import 'package:budgets/core/theme.dart';
import 'package:budgets/features/stats/domain/providers/stats_provider.dart';
import 'package:budgets/features/stats/presentation/widgets/balance_card.dart';
import 'package:budgets/features/stats/presentation/widgets/category_breakdown.dart';
import 'package:budgets/features/stats/presentation/pages/trends_page.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/widgets/custom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:budgets/features/stats/presentation/widgets/period_dropdown.dart';
import 'package:budgets/features/stats/presentation/modules/authentication_utils.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  late DateTime _previousStartDate;
  late DateTime _previousEndDate;
  bool _isBalanceVisible = false;
  bool _isPeriodBalanceVisible = false;
  bool _isIncomeVisible = false;
  bool _isExpensesVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeDates();
  }

  void _initializeDates() {
    final now = DateTime.now();
    // Default to current month
    _selectedStartDate = DateTime(now.year, now.month, 1);
    _selectedEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Previous period (last month, same number of days)
    final daysInCurrentPeriod =
        _selectedEndDate.difference(_selectedStartDate).inDays;
    _previousEndDate = _selectedStartDate.subtract(const Duration(days: 1));
    _previousStartDate =
        _previousEndDate.subtract(Duration(days: daysInCurrentPeriod));
  }

  void _onPeriodChanged(DateTime startDate, DateTime endDate) {
    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endDate;

      // Calculate previous period with same duration
      final daysInPeriod = endDate.difference(startDate).inDays;
      _previousEndDate = startDate.subtract(const Duration(days: 1));
      _previousStartDate =
          _previousEndDate.subtract(Duration(days: daysInPeriod));
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final allTimeBalanceAsync = ref.watch(allTimeBalanceProvider);
    final periodStatsAsync = ref.watch(
      periodStatsProvider(_selectedStartDate, _selectedEndDate),
    );
    final balanceComparisonAsync = ref.watch(
      balanceComparisonProvider(
        _selectedStartDate,
        _selectedEndDate,
        _previousStartDate,
        _previousEndDate,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        titleSpacing: 6.w,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Rapports',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          ActionButton(
              icon: Icons.trending_up,
              iconColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TrendsPage(),
                  ),
                );
              }),
          SizedBox(width: 6.w),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // All-time balance card - MOVED TO TOP
              allTimeBalanceAsync.when(
                data: (allTimeBalance) => BalanceCard(
                  title: 'Solde total',
                  amount: _isBalanceVisible ? allTimeBalance : 0,
                  subtitle: 'Tous vos revenus et dépenses',
                  isLarge: true,
                  isHidden: !_isBalanceVisible,
                  showVisibilityToggle: true,
                  onVisibilityToggle: () {
                    if (_isBalanceVisible) {
                      setState(() {
                        _isBalanceVisible = false;
                      });
                    } else {
                      AuthenticationUtils.authenticateAndShow(
                        context,
                        'Veuillez vous authentifier pour afficher le solde',
                        () {
                          setState(() {
                            _isBalanceVisible = true;
                          });
                        },
                      );
                    }
                  },
                ),
                loading: () => _buildLoadingCard(),
                error: (error, stack) => _buildErrorCard('Erreur: $error'),
              ),
              SizedBox(height: 2.h),

              // Period Selector - REDESIGNED AS DROPDOWN
              PeriodDropdown(
                selectedStartDate: _selectedStartDate,
                selectedEndDate: _selectedEndDate,
                onPeriodChanged: _onPeriodChanged,
                textColor: textColor,
              ),
              SizedBox(height: 2.h),

              // Current period balance with comparison
              balanceComparisonAsync.when(
                data: (balanceData) => Column(
                  children: [
                    BalanceCard(
                      title: 'Solde de la période',
                      amount: _isPeriodBalanceVisible
                          ? balanceData.currentPeriodBalance
                          : 0,
                      subtitle: 'Revenus - Dépenses',
                      comparisonAmount: balanceData.changeAmount,
                      comparisonPercentage: balanceData.changePercentage,
                      isPositiveChange: balanceData.isPositiveChange,
                      isHidden: !_isPeriodBalanceVisible,
                      showVisibilityToggle: true,
                      onVisibilityToggle: () {
                        if (_isPeriodBalanceVisible) {
                          setState(() {
                            _isPeriodBalanceVisible = false;
                          });
                        } else {
                          AuthenticationUtils.authenticateAndShow(
                            context,
                            'Veuillez vous authentifier pour afficher le solde de la période',
                            () {
                              setState(() {
                                _isPeriodBalanceVisible = true;
                              });
                            },
                          );
                        }
                      },
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          child: periodStatsAsync.when(
                            data: (stats) => BalanceCard(
                              title: 'Revenus',
                              amount: _isIncomeVisible ? stats.totalIncome : 0,
                              subtitle:
                                  '${stats.transactionCount} transactions',
                              isHidden: !_isIncomeVisible,
                              showVisibilityToggle: true,
                              onVisibilityToggle: () {
                                if (_isIncomeVisible) {
                                  setState(() {
                                    _isIncomeVisible = false;
                                  });
                                } else {
                                  AuthenticationUtils.authenticateAndShow(
                                    context,
                                    'Veuillez vous authentifier pour afficher les revenus',
                                    () {
                                      setState(() {
                                        _isIncomeVisible = true;
                                      });
                                    },
                                  );
                                }
                              },
                            ),
                            loading: () => _buildLoadingCard(),
                            error: (error, stack) => _buildErrorCard('Erreur'),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: periodStatsAsync.when(
                            data: (stats) => BalanceCard(
                              title: 'Dépenses',
                              amount:
                                  _isExpensesVisible ? -stats.totalExpenses : 0,
                              subtitle:
                                  '${stats.transactionCount} transactions',
                              isHidden: !_isExpensesVisible,
                              showVisibilityToggle: true,
                              onVisibilityToggle: () {
                                if (_isExpensesVisible) {
                                  setState(() {
                                    _isExpensesVisible = false;
                                  });
                                } else {
                                  AuthenticationUtils.authenticateAndShow(
                                    context,
                                    'Veuillez vous authentifier pour afficher les dépenses',
                                    () {
                                      setState(() {
                                        _isExpensesVisible = true;
                                      });
                                    },
                                  );
                                }
                              },
                            ),
                            loading: () => _buildLoadingCard(),
                            error: (error, stack) => _buildErrorCard('Erreur'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                loading: () => Column(
                  children: [
                    _buildLoadingCard(),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(child: _buildLoadingCard()),
                        SizedBox(width: 2.w),
                        Expanded(child: _buildLoadingCard()),
                      ],
                    ),
                  ],
                ),
                error: (error, stack) => _buildErrorCard('Erreur: $error'),
              ),
              SizedBox(height: 3.h),

              // Category Breakdown Title
              SizedBox(height: 2.h),
              Text(
                'Transactions par catégorie',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 2.h),
              periodStatsAsync.when(
                data: (stats) {
                  // Extract category colors and emojis from transactions
                  return ref.watch(transactionsProvider).when(
                        data: (transactions) {
                          final Map<String, String> categoryColors = {};
                          final Map<String, String> categoryEmojis = {};

                          for (final transaction in transactions) {
                            final categoryName = transaction.category?.name;
                            if (categoryName != null) {
                              categoryColors[categoryName] =
                                  transaction.category?.color ?? '#10B981';
                              categoryEmojis[categoryName] =
                                  transaction.category?.emoji ?? '💰';
                            }
                          }

                          return CategoryBreakdown(
                            expensesByCategory: stats.expensesByCategory,
                            incomeByCategory: stats.incomeByCategory,
                            categoryColors: categoryColors,
                            categoryEmojis: categoryEmojis,
                          );
                        },
                        loading: () => _buildLoadingCard(),
                        error: (error, stack) => _buildErrorCard('Erreur'),
                      );
                },
                loading: () => _buildLoadingCard(),
                error: (error, stack) => _buildErrorCard('Erreur: $error'),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLoadingCard() {
    final surfaceDim = Theme.of(context).colorScheme.surface;
    return Card(
      color: surfaceDim,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: SizedBox(
        height: 12.h,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceDim = Theme.of(context).colorScheme.surface;
    return Card(
      color: surfaceDim,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: SizedBox(
        height: 12.h,
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              color: textColor?.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
