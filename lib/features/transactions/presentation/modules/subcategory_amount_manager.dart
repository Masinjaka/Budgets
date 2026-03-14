import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/widgets/animated_amount_field.dart';
import 'package:flutter/material.dart';

/// Manages subcategory amount items: creation, validation, add/remove with animation.
class SubcategoryAmountManager {
  Map<String, dynamic> createItem() => {
        'subcategoryName': '',
        'subcategoryController': TextEditingController(),
        'amountController': AmountTextEditingController(),
      };

  bool validate(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return false;
    for (var item in items) {
      final name = item['subcategoryName'] as String?;
      final ctrl = item['amountController'] as TextEditingController?;
      if (name == null || name.isEmpty || ctrl == null || ctrl.text.trim().isEmpty) {
        return false;
      }
      try {
        parseAmountInput(ctrl.text.trim());
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  Map<String, String> buildAmountsMap(List<Map<String, dynamic>> items) {
    final map = <String, String>{};
    for (var item in items) {
      final name = item['subcategoryName'] as String?;
      final ctrl = item['amountController'] as TextEditingController?;
      if (name != null && name.isNotEmpty && ctrl != null && ctrl.text.trim().isNotEmpty) {
        map[name] = ctrl.text.trim();
      }
    }
    return map;
  }

  double calculateTotal(List<Map<String, dynamic>> items) {
    double total = 0.0;
    for (var item in items) {
      final ctrl = item['amountController'] as TextEditingController?;
      if (ctrl != null && ctrl.text.trim().isNotEmpty) {
        try {
          total += parseAmountInput(ctrl.text.trim());
        } catch (_) {}
      }
    }
    return total;
  }

  void add({
    required List<Map<String, dynamic>> items,
    required GlobalKey<AnimatedListState> listKey,
    required VoidCallback onStateChanged,
  }) {
    final idx = items.length;
    items.add(createItem());
    onStateChanged();
    listKey.currentState?.insertItem(idx);
  }

  void remove({
    required int index,
    required List<Map<String, dynamic>> items,
    required GlobalKey<AnimatedListState> listKey,
    required Widget Function(Map<String, dynamic>, int, Animation<double>) buildRemoved,
    required VoidCallback onStateChanged,
  }) {
    if (index >= items.length) return;
    final removed = items[index];
    items.removeAt(index);
    onStateChanged();
    listKey.currentState?.removeItem(
      index,
      (context, anim) => buildRemoved(removed, index, anim),
      duration: const Duration(milliseconds: 300),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      removed['subcategoryController']?.dispose();
      removed['amountController']?.dispose();
    });
  }

  void clearAll({
    required List<Map<String, dynamic>> items,
    required GlobalKey<AnimatedListState> listKey,
    required Widget Function(Map<String, dynamic>, int, Animation<double>) buildRemoved,
    required VoidCallback onStateChanged,
  }) {
    if (items.isEmpty) return;
    for (int i = items.length - 1; i >= 0; i--) {
      final removed = items[i];
      listKey.currentState?.removeItem(
        i,
        (context, anim) => buildRemoved(removed, i, anim),
        duration: Duration(milliseconds: 200 + (i * 50)),
      );
      Future.delayed(Duration(milliseconds: 250 + (i * 50)), () {
        removed['subcategoryController']?.dispose();
        removed['amountController']?.dispose();
      });
    }
    items.clear();
    onStateChanged();
  }
}
