import 'package:budgets/core/theme.dart';
import 'package:budgets/model/category_model.dart';
import 'package:budgets/provider/category_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: _appBar(context),
      body: _list(categoriesAsyncValue),
    );
  }

  Padding _list(AsyncValue<List<Category>> categoriesAsyncValue) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: switch (categoriesAsyncValue) {
              AsyncData(:final value) => _categoryGrid(value),
              AsyncError(:final error) => Text('error: $error'),
              _ => _skeleton(),
            },
          ),
        ],
      ),
    );
  }

  GridView _skeleton() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: 5,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
        childAspectRatio: 2.0, // This makes the height half of the width
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 119, 119, 119),
          borderRadius: BorderRadius.circular(5.w),
        ),
      ),
    );
  }

  _categoryGrid(List<Category> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'Aucune catégorie trouvée.',
          style: TextStyle(
        color: AppTheme.borderColorDark,
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
        childAspectRatio: 2.0, // This makes the height half of the width
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          // color: AppTheme.secondaryDark,
          color: Color(int.parse(categories[index].color!, radix: 16)),
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(
            color: AppTheme.borderColorDark,
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 2.w,
          children: [
            SizedBox(width: 4.w),
            Text(
              '${categories[index].emoji}',
              style: TextStyle(
                fontSize: 20.sp,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    offset: const Offset(1, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Text(
              '${categories[index].name}',
              style: TextStyle(
                fontSize: 15.sp,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    offset: const Offset(1, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(delay: (50 * index).ms)
          .fade(duration: 200.ms)
          .slideY(begin: 0.5, duration: 200.ms, curve: Curves.easeOut),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 10.h,
      title: Text(
        'Catégories',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: Center(
            child: CustomButton(
              backgroundColor: Colors.white,
              height: 4.h,
              width: 12.w,
              text: '+',
              onPressed: () {
                context.push('/add-category');
              },
            ),
          ),
        )
      ],
    );
  }
}
