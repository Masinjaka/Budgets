import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/features/transactions/presentation/modules/transaction_module.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/subcategory_amount_row.dart';
import 'package:flutter/material.dart';

class AnimatedSubcategoryItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final Animation<double> animation;
  final List<Subcategory> subcategories;
  final TransactionModule module;
  final List<Map<String, dynamic>> subcategoryAmounts;
  final GlobalKey<AnimatedListState> listKey;
  final VoidCallback onStateChanged;
  final Widget Function(Map<String, dynamic>, Animation<double>)
      buildRemovedItem;
  final void Function(Subcategory?, Map<String, dynamic>) onSubcategoryChanged;
  final void Function() onSubcategoryTapWithoutCategory;

  const AnimatedSubcategoryItem({
    super.key,
    required this.item,
    required this.index,
    required this.animation,
    required this.subcategories,
    required this.module,
    required this.subcategoryAmounts,
    required this.listKey,
    required this.onStateChanged,
    required this.buildRemovedItem,
    required this.onSubcategoryChanged,
    required this.onSubcategoryTapWithoutCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutBack)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: SubcategoryAmountRow(
          item: item,
          subcategories: subcategories,
          onAmountChanged: (_) {},
          onSubcategoryChanged: (sub) {
            if (sub != null) {
              (item['subcategoryController'] as TextEditingController).text =
                  sub.name ?? '';
              item['subcategoryName'] = sub.name ?? '';
              onSubcategoryChanged(sub, item);
            }
          },
          onSubcategoryTap: onSubcategoryTapWithoutCategory,
          onRemove: () => module.removeSubcategoryAmount(
            index: index,
            subcategoryAmounts: subcategoryAmounts,
            listKey: listKey,
            buildRemovedItem: (item, _, anim) => buildRemovedItem(item, anim),
            onStateChanged: onStateChanged,
          ),
          enabled: true,
        ),
      ),
    );
  }
}
