import 'dart:ui';

import 'package:budgets/core/theme.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../model/category_model.dart';
import '../../../features/categories/domain/providers/category_provider.dart';

class CategoryModule {
  // Add properties and methods as needed
  CategoryModule();

  // Example method
  void initialize() {
    // Initialization logic here
  }

  Future<void> addCategory(
    WidgetRef ref, {
    required String name,
    required String? emoji,
    required String color,
    TransactionType? transactionType,
    required BuildContext context,
    required GlobalKey<FormState> formKey,
  }) async {
    if (formKey.currentState!.validate()) {
      if (emoji == null || emoji.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('L\'emoticon est requis')),
        );
        return;
      }
      try {
        await ref.read(categoriesProvider.notifier).addSomeCategory(
              Category(
                name: name,
                emoji: emoji,
                color: color,
                transactionType: transactionType,
              ),
            );

        if (!context.mounted) return;
        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> editCategory(
    WidgetRef ref, {
    required String id,
    required String name,
    required String? emoji,
    required String color,
    TransactionType? transactionType,
    required BuildContext context,
    required GlobalKey<FormState> formKey,
  }) async {
    if (formKey.currentState!.validate()) {
      if (emoji == null || emoji.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('L\'emoticon est requis')),
        );
        return;
      }
      try {
        await ref.read(categoriesProvider.notifier).editSomeCategory(
              Category(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
                // transactionType: transactionType,
              ),
            );

        if (!context.mounted) return;
        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> deleteCategory(
      WidgetRef ref, Category category, BuildContext context) async {
    final String? result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.transparent),
            ),
            Center(
              child: AlertDialog(
                backgroundColor: AppTheme.secondaryDark,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: AppTheme.borderColorDark,
                  ),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                title: const Text('Supprimer la catégorie ?'),
                content: Text(
                  'T\'es sûr de vouloir retirer cette catégorie ?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop('deleted');
                    },
                    child: Text(
                      'Supprimer',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        await ref
            .read(categoriesProvider.notifier)
            .deleteSomeCategory(category);
        if (!context.mounted) return;
        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
