import 'package:budgets/core/theme.dart';
import 'package:budgets/features/stats/domain/providers/stats_provider.dart';
import 'package:budgets/features/stats/presentation/modules/balance_card.dart';
import 'package:budgets/features/stats/presentation/modules/category_breakdown.dart';
import 'package:budgets/features/stats/presentation/pages/trends_page.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:table_calendar/table_calendar.dart';

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
  bool _isBalanceVisible = true;
  final LocalAuthentication _localAuth = LocalAuthentication();

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleSpacing: 6.w,
        title: Text(
          'Statistiques',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.trending_up,
              color: textColor,
              size: 24.sp,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TrendsPage(),
                ),
              );
            },
            tooltip: 'Voir les tendances',
          ),
          SizedBox(width: 2.w),
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
                data: (allTimeBalance) => Stack(
                  children: [
                    BalanceCard(
                      title: 'Solde total',
                      amount: _isBalanceVisible ? allTimeBalance : 0,
                      subtitle: 'Tous vos revenus et dépenses',
                      isLarge: true,
                      isHidden: !_isBalanceVisible,
                    ),
                    Positioned(
                      top: 4.w,
                      right: 4.w,
                      child: IconButton(
                        icon: Icon(
                          _isBalanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20.sp,
                          color: textColor?.withValues(alpha: 0.6),
                        ),
                        onPressed: () {
                          if (_isBalanceVisible) {
                            // Hide immediately
                            setState(() {
                              _isBalanceVisible = false;
                            });
                          } else {
                            // Show authentication bottom sheet
                            _showAuthenticationBottomSheet();
                          }
                        },
                        tooltip: _isBalanceVisible ? 'Masquer' : 'Afficher',
                      ),
                    ),
                  ],
                ),
                loading: () => _buildLoadingCard(),
                error: (error, stack) => _buildErrorCard('Erreur: $error'),
              ),
              SizedBox(height: 2.h),

              // Period Selector - REDESIGNED AS DROPDOWN
              _buildPeriodDropdown(textColor),
              SizedBox(height: 2.h),

              // Current period balance with comparison
              balanceComparisonAsync.when(
                data: (balanceData) => Column(
                  children: [
                    BalanceCard(
                      title: 'Solde de la période',
                      amount: balanceData.currentPeriodBalance,
                      subtitle: 'Revenus - Dépenses',
                      comparisonAmount: balanceData.changeAmount,
                      comparisonPercentage: balanceData.changePercentage,
                      isPositiveChange: balanceData.isPositiveChange,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          child: periodStatsAsync.when(
                            data: (stats) => BalanceCard(
                              title: 'Revenus',
                              amount: stats.totalIncome,
                              subtitle:
                                  '${stats.transactionCount} transactions',
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
                              amount: -stats.totalExpenses,
                              subtitle:
                                  '${stats.transactionCount} transactions',
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

              // Category Breakdown
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

  Widget _buildPeriodDropdown(Color? textColor) {
    String getPeriodLabel() {
      final format = DateFormat('d MMM yyyy', 'fr_FR');
      if (_selectedStartDate.year == _selectedEndDate.year &&
          _selectedStartDate.month == _selectedEndDate.month &&
          _selectedStartDate.day == _selectedEndDate.day) {
        return format.format(_selectedStartDate);
      }
      return '${format.format(_selectedStartDate)} - ${format.format(_selectedEndDate)}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Période',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Builder(
          builder: (BuildContext buttonContext) {
            return GestureDetector(
              onTap: () => _showPeriodMenu(buttonContext),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getPeriodLabel(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: textColor,
                    size: 18.sp,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showPeriodMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()
            as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;

    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + buttonSize.height,
        buttonPosition.dx + buttonSize.width,
        buttonPosition.dy + buttonSize.height,
      ),
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.w),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'today',
          child: Row(
            children: [
              Icon(Icons.today, size: 16.sp, color: textColor),
              SizedBox(width: 3.w),
              Text(
                'Aujourd\'hui',
                style: TextStyle(color: textColor, fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'week',
          child: Row(
            children: [
              Icon(Icons.date_range, size: 16.sp, color: textColor),
              SizedBox(width: 3.w),
              Text(
                'Cette semaine',
                style: TextStyle(color: textColor, fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'month',
          child: Row(
            children: [
              Icon(Icons.calendar_month, size: 16.sp, color: textColor),
              SizedBox(width: 3.w),
              Text(
                'Ce mois',
                style: TextStyle(color: textColor, fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'year',
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16.sp, color: textColor),
              SizedBox(width: 3.w),
              Text(
                'Cette année',
                style: TextStyle(color: textColor, fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'custom',
          child: Row(
            children: [
              Icon(Icons.edit_calendar, size: 16.sp, color: textColor),
              SizedBox(width: 3.w),
              Text(
                'Personnalisée',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        _handlePeriodSelection(value);
      }
    });
  }

  void _handlePeriodSelection(String value) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (value) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        _onPeriodChanged(startDate, endDate);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        _onPeriodChanged(startDate, endDate);
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        _onPeriodChanged(startDate, endDate);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        _onPeriodChanged(startDate, endDate);
        break;
      case 'custom':
        _showCustomDatePicker();
        break;
    }
  }

  void _showCustomDatePicker() {
    showDialog(
      context: context,
      builder: (context) => _CustomDateRangeDialog(
        initialStartDate: _selectedStartDate,
        initialEndDate: _selectedEndDate,
        onConfirm: (start, end) {
          _onPeriodChanged(start, end);
        },
      ),
    );
  }
  Future<void> _showAuthenticationBottomSheet() async {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    await showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: textColor?.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            SizedBox(height: 3.h),
            Icon(
              Icons.lock_outline,
              size: 40.sp,
              color: textColor?.withValues(alpha: 0.7),
            ),
            SizedBox(height: 2.h),
            Text(
              'Authentification requise',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Veuillez vous authentifier pour afficher le solde',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: textColor?.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authenticateAndShowBalance();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fingerprint, size: 20.sp),
                  SizedBox(width: 2.w),
                  Text(
                    'Authentifier',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Future<void> _authenticateAndShowBalance() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        // Device doesn't support biometrics, show balance directly
        setState(() {
          _isBalanceVisible = true;
        });
        return;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour afficher le solde',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuthenticate) {
        setState(() {
          _isBalanceVisible = true;
        });
      }
    } on PlatformException catch (e) {
      // Handle authentication errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'authentification: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

class _CustomDateRangeDialog extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime start, DateTime end) onConfirm;

  const _CustomDateRangeDialog({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onConfirm,
  });

  @override
  State<_CustomDateRangeDialog> createState() => _CustomDateRangeDialogState();
}

class _CustomDateRangeDialogState extends State<_CustomDateRangeDialog> {
  late DateTime _focusedDay;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialStartDate;
    _selectedStartDate = widget.initialStartDate;
    _selectedEndDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sélectionner une période',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 2.h),
            TableCalendar(
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              locale: 'fr_FR',
              rangeStartDay: _selectedStartDate,
              rangeEndDay: _selectedEndDate,
              rangeSelectionMode: _rangeSelectionMode,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor:
                    AppTheme.primaryGreen.withValues(alpha: 0.2),
                withinRangeTextStyle: TextStyle(color: textColor),
                outsideDaysVisible: false,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _selectedStartDate = start ?? _selectedStartDate;
                  _selectedEndDate = end ?? _selectedEndDate;
                  _focusedDay = focusedDay;
                });
              },
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                ElevatedButton(
                  onPressed: () {
                    final start = DateTime(
                      _selectedStartDate.year,
                      _selectedStartDate.month,
                      _selectedStartDate.day,
                    );
                    final end = DateTime(
                      _selectedEndDate.year,
                      _selectedEndDate.month,
                      _selectedEndDate.day,
                      23,
                      59,
                      59,
                    );
                    widget.onConfirm(start, end);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                  ),
                  child: Text(
                    'Confirmer',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
