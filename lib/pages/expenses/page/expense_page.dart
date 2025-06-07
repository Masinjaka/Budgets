import 'package:budgets/core/theme.dart';
import 'package:budgets/provider/auth_provider.dart';
import 'package:budgets/widgets/custom_app_bar.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpensePage extends ConsumerStatefulWidget {
  const ExpensePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpensePageState();
}

class _ExpensePageState extends ConsumerState<ExpensePage> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              Expanded(
                flex: 7,
                child: Container(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildSignoutButton(),
    );
  }

  Container _buildExpenseTotal() {
    return Container(
      padding: EdgeInsets.all(2.w),
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

  Padding _buildSignoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.w),
      child: CustomButton(
        text: 'Ajouter un achat',
        onPressed: () async {
          // start authenticating
          setState(() => _isLoading = true);
          await ref.read(authProvider.notifier).signOut();
          if (!mounted) return;
          context.go('/login');
          setState(() => _isLoading = false);
          // end authenticating
        },
        isLoading: _isLoading,
      ),
    );
  }
}
