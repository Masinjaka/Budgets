import 'package:budgets/core/theme.dart';
import 'package:budgets/model/category_model.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:budgets/widgets/expense_widgets/transaction_widget.dart';
import 'package:budgets/widgets/custom_action_button.dart';
import 'package:budgets/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpenseList extends ConsumerStatefulWidget {
  const ExpenseList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExplenseListState();
}

class _ExplenseListState extends ConsumerState<ExpenseList> {
  // Grouped transaction data for the list
  final Map<String, List<Expense>> groupedTransactions = {
    "Aujourd'hui": [
      Expense(
        category: Category(name: 'Courses', emoji: '🍑'),
        description: 'Description de la transaction',
        amount: 10000,
      ),
      Expense(
        category: Category(name: 'Courses', emoji: '🍑'),
        description: 'Description de la transaction',
        amount: 10000,
      ),
      Expense(
        category: Category(name: 'Courses', emoji: '🍑'),
        description: 'Description de la transaction',
        amount: 10000,
      ),
    ],
    '10 Septembre 2025': [
      Expense(
        category: Category(name: 'Courses', emoji: '🍑'),
        description: 'Description de la transaction',
        amount: 10000,
      ),
    ],
    '07 Septembre 2025': [
      Expense(
        category: Category(name: 'Courses', emoji: '🍑'),
        description: 'Description de la transaction',
        amount: 10000,
      ),
      Expense(
        category: Category(name: 'Courses', emoji: '🍑'),
        description: 'Description de la transaction',
        amount: 10000,
      ),
    ],
    '06 Septembre 2025': [
      Expense(
        category: Category(name: 'Courses', emoji: '🍑'),
        description: 'Description de la transaction',
        amount: 10000,
      ),
      Expense(
        category: Category(name: 'Courses', emoji: '🍑'),
        description: 'Description de la transaction',
        amount: 10000,
      ),
      Expense(
        category: Category(name: 'Courses', emoji: '🍑'),
        description: 'Description de la transaction',
        amount: 10000,
      ),
      Expense(
        category: Category(name: 'Courses', emoji: '🍑'),
        description: 'Description de la transaction',
        amount: 10000,
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            // The collapsing app bar with search bar
            SliverAppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: AppTheme.backgroundDark,
              pinned: true,
              floating: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  context.pop();
                },
              ),
              title: Text(
                'Dépenses',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
              centerTitle: false,
              actions: [
                // Reusable action buttons in the app bar
                ActionButton(icon: Icons.fullscreen, onPressed: () {}),
                SizedBox(width: 2.w),
                ActionButton(icon: Icons.add, onPressed: () {}),
                SizedBox(width: 2.w),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                  padding:
                      EdgeInsets.fromLTRB(2.w, 2.h, 2.w, 1.h),
                  child: Row(
                    children: [
                      const Expanded(
                        child: ReusableSearchBar(),
                      ),
                      SizedBox(width: 1.h),
                      ActionButton(
                        icon: Icons.filter_list_rounded,
                        onPressed: () {},
                        isSquare: true,
                        backgroundColor: AppTheme.secondaryDark,
                      ),
                    ],
                  ),
                ),
            ),
          ];
        },
        body: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: groupedTransactions.length,
          itemBuilder: (context, index) {
            final date = groupedTransactions.keys.elementAt(index);
            final transactions = groupedTransactions[date]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(2.w, 2.w, 2.w, 2.w),
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
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
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
  }
}
