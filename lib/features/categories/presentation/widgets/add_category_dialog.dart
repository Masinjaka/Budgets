import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// A simplified dialog for adding a new category.
class AddCategoryDialog extends ConsumerStatefulWidget {
  final TransactionType transactionType;

  const AddCategoryDialog({
    super.key,
    required this.transactionType,
  });

  /// Shows the add category dialog and returns the created category if successful.
  static Future<Category?> show(
    BuildContext context, {
    required TransactionType transactionType,
  }) {
    return showAnimatedDialog<Category?>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddCategoryDialog(
        transactionType: transactionType,
      ),
    );
  }

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  String _selectedEmoji = '📁';
  Color _selectedColor = const Color(0xFF6C5CE7);
  bool _isLoading = false;

  // Common emojis for categories
  static const List<String> _commonEmojis = [
    '🛒',
    '🍔',
    '🚗',
    '🏠',
    '💡',
    '📱',
    '🎬',
    '🎮',
    '👕',
    '💊',
    '📚',
    '✈️',
    '🎁',
    '💰',
    '💳',
    '🏦',
    '📈',
    '💼',
    '🎓',
    '🏥',
    '🚌',
    '⛽',
    '🍕',
    '☕',
    '🍺',
    '🎵',
    '🏋️',
    '💇',
    '🐕',
    '👶',
    '🔧',
    '🌐',
    '📦',
    '🎂',
    '💐',
    '🏪',
    '🎯',
    '📝',
    '🔌',
    '📁',
  ];

  // Common colors for categories
  static const List<Color> _commonColors = [
    Color(0xFF6C5CE7), // Purple
    Color(0xFF0984E3), // Blue
    Color(0xFF00B894), // Green
    Color(0xFFE17055), // Orange
    Color(0xFFD63031), // Red
    Color(0xFFFDAA5D), // Light Orange
    Color(0xFF74B9FF), // Light Blue
    Color(0xFF55EFC4), // Mint
    Color(0xFFFF7675), // Pink
    Color(0xFFA29BFE), // Light Purple
    Color(0xFF636E72), // Gray
    Color(0xFFFFD93D), // Yellow
  ];

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
                        'Nouvelle catégorie',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Center(
                  child: GestureDetector(
                    onTap: _showEmojiPicker,
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(50.w),
                        border: Border.all(
                          color: _selectedColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _selectedEmoji,
                          style: TextStyle(fontSize: 22.sp),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                // Emoji and Name row
                CustomTextField(
                  title: const SizedBox.shrink(),
                  hint: 'Nom de la catégorie',
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  // borderRadius: BorderRadius.circular(3.w),
                  validator: const <String, String>{"type": "required"},
                ),
                SizedBox(height: 2.5.h),

                // Color selector
                Text(
                  'Couleur',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                _buildColorSelector(),
                SizedBox(height: 3.h),

                // Submit button
                CustomButton(
                  text: 'Créer',
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: _submitCategory,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.5.h,
      children: _commonColors.map((color) {
        final isSelected = _selectedColor.value == color.value;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 9.w,
            height: 9.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.white
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14.sp,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  void _showEmojiPicker() {
    showAnimatedDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choisir un emoji',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.5.h,
                children: _commonEmojis.map((emoji) {
                  final isSelected = _selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmoji = emoji;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 11.w,
                      height: 11.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(2.w),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Store color as hex value without # prefix (same format as existing code)
      final colorHex = _selectedColor.value.toRadixString(16);

      // Wait for the provider to be ready before accessing the notifier
      // This ensures the async provider is properly initialized
      await ref.read(categoriesProvider.future);

      await ref.read(categoriesProvider.notifier).addSomeCategory(
            Category(
              name: _nameController.text.trim(),
              emoji: _selectedEmoji,
              color: colorHex,
              transactionType: widget.transactionType,
            ),
          );

      if (!mounted) return;

      // Return the created category
      final newCategory = Category(
        name: _nameController.text.trim(),
        emoji: _selectedEmoji,
        color: colorHex,
        transactionType: widget.transactionType,
      );

      Navigator.of(context).pop(newCategory);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
