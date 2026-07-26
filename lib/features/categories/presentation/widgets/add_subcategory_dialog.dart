import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

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
    return showAnimatedDialog<Subcategory?>(
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
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
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
                          fontSize: 17,
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
                        iconSize: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Name field
                CustomTextField(
                  title: const SizedBox.shrink(),
                  hint: 'Nom de la sous-catégorie',
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  borderRadius: BorderRadius.circular(12),
                  validator: const <String, String>{"type": "required"},
                ),
                SizedBox(height: 24),

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
