import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// A minimal dialog for adding a new subcategory.
/// Returns a temporary Subcategory with just the name (no id).
/// The actual creation happens on transaction submit via the RPC.
class AddSubcategoryDialog extends StatefulWidget {
  final String? categoryId;

  const AddSubcategoryDialog({
    super.key,
    this.categoryId,
  });

  /// Shows the add subcategory dialog.
  /// Returns the new [Subcategory] or null if dismissed.
  static Future<Subcategory?> show(
    BuildContext context, {
    String? categoryId,
  }) {
    return showDialog<Subcategory?>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddSubcategoryDialog(
        categoryId: categoryId,
      ),
    );
  }

  @override
  State<AddSubcategoryDialog> createState() => _AddSubcategoryDialogState();
}

class _AddSubcategoryDialogState extends State<AddSubcategoryDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.w),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Nouvelle sous-catégorie',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 18.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Name field
                CustomTextField(
                  title: const SizedBox.shrink(),
                  hint: 'Nom de la sous-catégorie',
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  borderRadius: BorderRadius.circular(3.w),
                  validator: const <String, String>{"type": "required"},
                ),
                SizedBox(height: 3.h),

                // Confirm button
                CustomButton(
                  text: 'Confirmer',
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    // Return a temporary subcategory (no id, will be created on transaction submit)
    final newSubcategory = Subcategory(
      name: name,
      categoryId: widget.categoryId,
    );

    Navigator.of(context).pop(newSubcategory);
  }
}
