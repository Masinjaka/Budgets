import 'package:budgets/core/theme.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:budgets/provider/expense_provider.dart';
import 'package:budgets/widgets/custom_app_bar.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_expense_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpensePage extends ConsumerStatefulWidget {
  const ExpensePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpensePageState();
}

class _ExpensePageState extends ConsumerState<ExpensePage> {
  @override
  Widget build(BuildContext context) {
    final asyncExpenses = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        toolbarHeight: 8.h,
        elevation: 0,
        title: const CustomAppBar(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7.w),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: _buildExpenseTotal(),
              ),
              SizedBox(height: 1.h),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dépenses récentes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5.sp,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.h),
                        border: Border.all(color: Colors.black),
                      ),
                      child: const Icon(
                        Icons.filter_alt_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
              Expanded(
                flex: 7,
                child: SizedBox(
                  height: double.infinity,
                  child: switch (asyncExpenses) {
                    AsyncData(:final value) => _buildExpenseList(value),
                    AsyncError(:final error) => Text('error: $error'),
                    _ => const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildAddButton(),
    );
  }

  SingleChildScrollView _buildExpenseList(List<Expense> expenses) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: expenses.map((e) => ExpenseTile(
            designation: e.title??"Designation inconnue",
            category: e.category?.name??"Categorie inconnue",
            amount: e.amount?.toString() ?? "Montant inconnue",
            date: e.date!,
          ),).toList(),
        
      ),
    );
  }

  Container _buildExpenseTotal() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Mes depenses ce mois-ci',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.5.sp,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ar 100 000',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.sp,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.h),
                border: Border.all(color: Colors.black),
              ),
              child: const Icon(
                Icons.insights,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildAddButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: CustomButton(
        text: 'Ajouter un achat',
        onPressed: () async {
          if (!mounted) return;
          context.push('/add-expense');
        },
      ),
    );
  }
}

class Pills extends StatelessWidget {
  const Pills({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.1.h),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 250, 200, 108),
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: Colors.black,
        ),
      ),
    );
  }
}
