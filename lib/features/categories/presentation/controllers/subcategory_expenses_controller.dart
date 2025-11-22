import 'dart:async';

import 'package:budgets/features/categories/domain/models/subcategory_transaction.dart';
import 'package:budgets/features/categories/domain/providers/subcategory_expenses_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subcategory_expenses_controller.g.dart';

@riverpod
class SubcategoryExpensesController extends _$SubcategoryExpensesController {
  @override
  FutureOr<List<SubcategoryTransaction>> build() {
    return [];
  }

  Future<void> fetch(String transactionId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.watch(subcategoryExpensesProvider(transactionId).future);
    });
  }
}
