import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensePage extends ConsumerStatefulWidget {
  const ExpensePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpensePageState();
}

class _ExpensePageState extends ConsumerState<ExpensePage> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Expense page'),
      ),
    );
  }
}