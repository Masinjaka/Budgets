import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/categories/data/datasource/category_api.dart'
    as category_api;
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/planning/data/datasources/goal_datasource.dart'
    as goal_datasource;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CategoryTabContent extends ConsumerWidget {
  final TransactionType transactionType;

  const CategoryTabContent({
    super.key,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: switch (categoriesAsyncValue) {
              AsyncData(:final value) =>
                _categoryGrid(context, _filterCategories(value)),
              AsyncError(:final error) => Text('error: $error'),
              _ => _skeleton(context),
            },
          ),
        ],
      ),
    );
  }

  List<Category> _filterCategories(List<Category> categories) {
    return categories
        .where((category) => category.transactionType == transactionType)
        .toList();
  }

  GridView _skeleton(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: 5,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
        childAspectRatio: 2.0,
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5.w),
        ),
      ),
    );
  }

  Widget _categoryGrid(BuildContext context, List<Category> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'Aucune catégorie trouvée.',
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 16.sp,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
        childAspectRatio: 2.0,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSavingsCategory = category_api.isSavingsCategory(category);

        return GestureDetector(
          onTap: () async {
            if (isSavingsCategory) {
              final hasGoals = await goal_datasource.hasAnyGoals();
              if (hasGoals) {
                if (context.mounted) {
                  showInfoToast(
                    context,
                    'Cette catégorie est utilisée pour vos objectifs d\'épargne et ne peut pas être modifiée.',
                  );
                }
                return;
              }
            }
            if (context.mounted) {
              context.push('/add-category', extra: category);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(int.parse(category.color!, radix: 16)),
              borderRadius: BorderRadius.circular(5.w),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isSavingsCategory)
                  Positioned(
                    top: 2.w,
                    right: 2.w,
                    child: FutureBuilder<bool>(
                      future: goal_datasource.hasAnyGoals(),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return Icon(
                            Icons.lock_outline,
                            color: Colors.white.withOpacity(0.7),
                            size: 14.sp,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                Positioned.fill(
                  right: -5.w,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: RotationTransition(
                      turns: const AlwaysStoppedAnimation(-25 / 360),
                      child: Text(
                        '${category.emoji}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 35.sp,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  left: 5.w,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${category.name}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate(delay: (50 * index).ms)
            .fade(duration: 200.ms)
            .slideY(begin: 0.5, duration: 200.ms, curve: Curves.easeOut);
      },
    );
  }
}
