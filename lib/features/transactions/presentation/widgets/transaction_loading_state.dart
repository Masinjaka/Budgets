import 'package:flutter/material.dart';

class TransactionLoadingState extends StatelessWidget {
  const TransactionLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
