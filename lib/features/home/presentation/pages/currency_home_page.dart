import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencyHomePage extends ConsumerWidget {
  const CurrencyHomePage({required this.isSignedIn, super.key});

  final bool Function() isSignedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyControllerProvider).value;
    return ChatHomePage(
      isSignedIn: isSignedIn,
      currencyState: currency,
    );
  }
}
