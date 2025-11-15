import 'package:budgets/core/theme.dart';
import 'package:budgets/model/category_model.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:budgets/provider/expense_provider.dart';
import 'package:budgets/widgets/expense_widgets/transaction_widget.dart';
import 'package:budgets/widgets/custom_action_button.dart';
import 'package:budgets/widgets/custom_search_bar.dart';
import 'package:budgets/widgets/category_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ExpenseList extends ConsumerStatefulWidget {
  const ExpenseList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExplenseListState();
}

class _ExplenseListState extends ConsumerState<ExpenseList>
    with TickerProviderStateMixin {
  // Search state management
  bool isSearchFocused = false;
  final TextEditingController searchController = TextEditingController();
  
  // Animation controller for SliverAppBar
  late AnimationController _appBarAnimationController;
  late Animation<double> _appBarAnimation;

  // Selected categories for filtering
  List<Category> selectedCategories = [];

  // Locale initialization flag
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _appBarAnimation = CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.easeInOut,
    );
    // Start with app bar visible
    _appBarAnimationController.value = 1.0;
    
    // Initialize French locale for date formatting
    _initializeLocale();
    
    // Add listener for real-time search
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Trigger rebuild when search text changes
    setState(() {});
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('fr', null);
    if (mounted) {
      setState(() {
        _localeInitialized = true;
      });
    }
  }

  void _onCategorySelectionChanged(List<Category> categories) {
    setState(() {
      selectedCategories = categories;
    });
  }

  /// Groups expenses by date and formats the date strings
  Map<String, List<Expense>> _groupExpensesByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final expense in expenses) {
      if (expense.date == null) continue;

      final expenseDate = DateTime(
        expense.date!.year,
        expense.date!.month,
        expense.date!.day,
      );

      String dateKey;
      if (expenseDate.isAtSameMomentAs(today)) {
        dateKey = "Aujourd'hui";
      } else if (expenseDate.isAtSameMomentAs(yesterday)) {
        dateKey = "Hier";
      } else {
        // Use French formatting if locale is initialized, otherwise use default
        if (_localeInitialized) {
          dateKey = DateFormat('dd MMMM yyyy', 'fr').format(expense.date!);
        } else {
          dateKey = DateFormat('dd MMMM yyyy').format(expense.date!);
        }
      }

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(expense);
    }

    // Sort each group by time (most recent first)
    grouped.forEach((key, value) {
      value.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    });

    return grouped;
  }

  /// Filters expenses based on search text and selected categories
  List<Expense> _filterExpenses(List<Expense> expenses) {
    List<Expense> filteredExpenses = expenses;

    // Filter by search text
    final searchText = searchController.text.toLowerCase().trim();
    if (searchText.isNotEmpty) {
      filteredExpenses = filteredExpenses.where((expense) {
        final description = expense.description?.toLowerCase() ?? '';
        final title = expense.title?.toLowerCase() ?? '';
        final categoryName = expense.category?.name?.toLowerCase() ?? '';
        
        return description.contains(searchText) ||
               title.contains(searchText) ||
               categoryName.contains(searchText);
      }).toList();
    }

    // Filter by selected categories
    if (selectedCategories.isNotEmpty) {
      final selectedCategoryIds = selectedCategories
          .map((cat) => cat.id)
          .where((id) => id != null)
          .toSet();
      
      filteredExpenses = filteredExpenses.where((expense) {
        return expense.category?.id != null &&
               selectedCategoryIds.contains(expense.category!.id);
      }).toList();
    }

    return filteredExpenses;
  }

  /// Extracts unique categories from expenses
  List<Category> _extractCategoriesFromExpenses(List<Expense> expenses) {
    final Set<String> seenCategoryIds = {};
    final List<Category> categories = [];

    for (final expense in expenses) {
      final category = expense.category;
      if (category != null && 
          category.id != null && 
          !seenCategoryIds.contains(category.id)) {
        seenCategoryIds.add(category.id!);
        categories.add(category);
      }
    }

    // Sort categories alphabetically
    categories.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    return categories;
  }

  void _onSearchFocused() {
    setState(() {
      isSearchFocused = true;
    });
    _appBarAnimationController.animateTo(0.0);
  }

  void _onSearchUnfocused() {
    setState(() {
      isSearchFocused = false;
    });
    _appBarAnimationController.animateTo(1.0);
    FocusScope.of(context).unfocus();
  }

  void _onClearSearch() {
    searchController.clear();
    // The listener will automatically trigger setState() when text changes
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    _appBarAnimationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch expense data from provider
    final asyncExpenses = ref.watch(expensesProvider);
    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: asyncExpenses.when(
          data: (expenses) {
            // Filter and group expenses
            final filteredExpenses = _filterExpenses(expenses);
            final groupedTransactions = _groupExpensesByDate(filteredExpenses);
            final availableCategories = _extractCategoriesFromExpenses(expenses);
        
            return NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  // Smoothly animated SliverAppBar
                  AnimatedBuilder(
                    animation: _appBarAnimation,
                    builder: (context, child) {
                      return SliverAppBar(
                        surfaceTintColor: Colors.transparent,
                        backgroundColor: AppTheme.backgroundDark,
                        pinned: true,
                        floating: true,
                        expandedHeight: _appBarAnimation.value * kToolbarHeight,
                        toolbarHeight: _appBarAnimation.value * kToolbarHeight,
                        elevation: _appBarAnimation.value * 4,
                        titleSpacing: 6.w,
                        title: _appBarAnimation.value > 0.1 ? Opacity(
                          opacity: _appBarAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - _appBarAnimation.value) * -20),
                            child: Text(
                              'Transactions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 18.sp,
                                color: Colors.white.withOpacity(_appBarAnimation.value),
                              ),
                            ),
                          ),
                        ) : null,
                        centerTitle: false,
                        actions: _appBarAnimation.value > 0.1 ? [
                          Opacity(
                            opacity: _appBarAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - _appBarAnimation.value) * -20),
                              child: ActionButton(
                                  icon: Icons.fullscreen,
                                  iconColor: AppTheme.secondaryDark,
                                  backgroundColor: AppTheme.primaryGreen,
                                  onPressed: () {}),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Opacity(
                            opacity: _appBarAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - _appBarAnimation.value) * -20),
                              child: ActionButton(
                                  icon: Icons.add,
                                  iconColor: AppTheme.secondaryDark,
                                  backgroundColor: AppTheme.primaryGreen,
                                  onPressed: () {
                                    context.push("/add-expense");
                                  }),
                            ),
                          ),
                          SizedBox(width: 6.w),
                        ] : [],
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.fromLTRB(
                        6.w, 
                        isSearchFocused ? 2.h : 2.h, // Same padding whether focused or not
                        6.w, 
                        1.h
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ReusableSearchBar(
                              isSearchFocused: isSearchFocused,
                              onSearchFocused: _onSearchFocused,
                              onSearchUnfocused: _onSearchUnfocused,
                              onClearSearch: _onClearSearch,
                              controller: searchController,
                              hintText: 'Rechercher...',
                            ),
                          ),
                          if (!isSearchFocused) ...[
                            SizedBox(width: 1.h),
                            ActionButton(
                              icon: Icons.filter_list_rounded,
                              onPressed: () {},
                              isSquare: true,
                              backgroundColor: AppTheme.secondaryDark,
                            ).animate().fadeIn(
                              duration: 200.ms,
                              delay: 100.ms,
                            ).scaleXY(
                              begin: 0.8,
                              end: 1.0,
                              duration: 200.ms,
                              delay: 100.ms,
                              curve: Curves.easeOutBack,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Show filter widget only when search is focused with animation
                  if (isSearchFocused)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(6.w, 1.h, 6.w, 1.h),
                        child: CategoryFilterWidget(
                          categories: availableCategories,
                          selectedCategories: selectedCategories,
                          onSelectionChanged: _onCategorySelectionChanged,
                        ).animate().slideY(
                          begin: -0.3,
                          end: 0,
                          duration: 400.ms,
                          delay: 150.ms,
                          curve: Curves.easeOutCubic,
                        ).fadeIn(
                          duration: 350.ms,
                          delay: 100.ms,
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ),
                ];
              },
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: groupedTransactions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: groupedTransactions.length,
                        itemBuilder: (context, index) {
                          final date = groupedTransactions.keys.elementAt(index);
                          final transactions = groupedTransactions[date]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 2.w, 0, 2.w),
                                child: Text(
                                  date,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5.sp,
                                  ),
                                ),
                              ),
                              // ListView for transactions under a specific date
                              ListView.separated(
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: transactions.length,
                                itemBuilder: (context, i) {
                                  return TransactionListItem(transaction: transactions[i]);
                                },
                                separatorBuilder: (context, i) => SizedBox(height: 1.h),
                              ),
                              SizedBox(height: 2.h),
                            ],
                          );
                        },
                      ),
              ),
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error),
        ),
      ),
    );
  }

  /// Build loading state widget
  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(Object error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            SizedBox(height: 2.h),
            Text(
              'Erreur lors du chargement des dépenses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              error.toString(),
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(expensesProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.secondaryDark,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            selectedCategories.isNotEmpty || searchController.text.isNotEmpty
                ? 'Aucune dépense trouvée'
                : 'Aucune dépense enregistrée',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            selectedCategories.isNotEmpty || searchController.text.isNotEmpty
                ? 'Essayez de modifier vos filtres'
                : 'Commencez par ajouter vos premières dépenses',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
