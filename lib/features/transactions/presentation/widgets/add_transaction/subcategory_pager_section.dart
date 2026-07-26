import 'package:budgets/features/transactions/presentation/widgets/add_transaction/add_subcategory_card.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/subcategory_amount_card.dart';
import 'package:flutter/material.dart';

export 'subcategory_amount_card_widget.dart';

class SubcategoryPagerSection extends StatelessWidget {
  final List<Map<String, dynamic>> subcategoryAmounts;
  final PageController pageController;
  final Set<int> removingIndices;
  final int? newlyAddedIndex;
  final void Function(int) onRemove;
  final VoidCallback onAdd;
  final Future<void> Function(Map<String, dynamic>, int) onSubcategoryTap;

  const SubcategoryPagerSection({
    super.key,
    required this.subcategoryAmounts,
    required this.pageController,
    required this.removingIndices,
    required this.newlyAddedIndex,
    required this.onRemove,
    required this.onAdd,
    required this.onSubcategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: pageController,
        padEnds: true,
        itemCount: subcategoryAmounts.length + 1,
        itemBuilder: (context, index) {
          if (index == subcategoryAmounts.length) {
            return AddSubcategoryCard(onAdd: onAdd);
          }
          final isRemoving = removingIndices.contains(index);
          final isNewlyAdded = newlyAddedIndex == index;

          Widget card = SubcategoryAmountCard(
            item: subcategoryAmounts[index],
            index: index,
            onRemove: onRemove,
            onSubcategoryTap: onSubcategoryTap,
          );

          if (isNewlyAdded) {
            card = TweenAnimationBuilder<Offset>(
              tween: Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, offset, child) =>
                  FractionalTranslation(translation: offset, child: child),
              child: card,
            );
          }

          return AnimatedScale(
            scale: isRemoving ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: isRemoving ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: card,
            ),
          );
        },
      ),
    );
  }
}
