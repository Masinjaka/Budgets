import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../model/category_model.dart';
import '../../../provider/category_provider.dart';

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
              ),
            );
        
        if(!context.mounted) return;
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
}
