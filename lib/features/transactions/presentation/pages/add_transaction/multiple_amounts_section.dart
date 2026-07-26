import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/features/transactions/presentation/modules/transaction_module.dart';
import 'package:budgets/features/transactions/presentation/pages/add_transaction/animated_subcategory_item.dart';
import 'package:budgets/widgets/custom_border_painter.dart';
import 'package:flutter/material.dart';

class MultipleAmountsSection extends StatelessWidget {
  final List<Map<String, dynamic>> subcategoryAmounts;
  final List<Subcategory> subcategories;
  final GlobalKey<AnimatedListState> listKey;
  final TransactionModule module;
  final VoidCallback onStateChanged;
  final Widget Function(Map<String, dynamic>, Animation<double>)
      buildRemovedItem;
  final void Function(Subcategory?, Map<String, dynamic>) onSubcategoryChanged;
  final void Function() onSubcategoryTapWithoutCategory;

  const MultipleAmountsSection({
    super.key,
    required this.subcategoryAmounts,
    required this.subcategories,
    required this.listKey,
    required this.module,
    required this.onStateChanged,
    required this.buildRemovedItem,
    required this.onSubcategoryChanged,
    required this.onSubcategoryTapWithoutCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Montants par sous-catégories',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
        SizedBox(height: 12),
        AnimatedList(
          key: listKey,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: subcategoryAmounts.length,
          itemBuilder: (context, index, animation) {
            if (index >= subcategoryAmounts.length)
              return const SizedBox.shrink();
            return AnimatedSubcategoryItem(
              item: subcategoryAmounts[index],
              index: index,
              animation: animation,
              subcategories: subcategories,
              module: module,
              subcategoryAmounts: subcategoryAmounts,
              listKey: listKey,
              onStateChanged: onStateChanged,
              buildRemovedItem: buildRemovedItem,
              onSubcategoryChanged: onSubcategoryChanged,
              onSubcategoryTapWithoutCategory: onSubcategoryTapWithoutCategory,
            );
          },
        ),
        GestureDetector(
          onTap: () => module.addSubcategoryAmount(
            subcategoryAmounts: subcategoryAmounts,
            listKey: listKey,
            onStateChanged: onStateChanged,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 6),
            child: CustomPaint(
              painter: DashedBorderPainter(
                  color: Theme.of(context).dividerColor.withAlpha(128),
                  strokeWidth: 1.0,
                  borderRadius: 20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add,
                        color: Theme.of(context).iconTheme.color, size: 16),
                    SizedBox(width: 8),
                    Text('Ajouter une sous-catégorie',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
