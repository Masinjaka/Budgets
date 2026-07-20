import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_category_field.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_type_selector.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManualEntrySheet extends StatefulWidget {
  const ManualEntrySheet({
    required this.categories,
    required this.targetDate,
    super.key,
  });

  final List<ManualEntryCategory> categories;
  final DateTime targetDate;

  static Future<ManualEntryInput?> show(
    BuildContext context, {
    required List<ManualEntryCategory> categories,
    required DateTime targetDate,
  }) {
    return showModalBottomSheet<ManualEntryInput>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManualEntrySheet(
        categories: categories,
        targetDate: targetDate,
      ),
    );
  }

  @override
  State<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<ManualEntrySheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'expense';
  String? _categoryId;

  List<ManualEntryCategory> get _categories => widget.categories
      .where((category) => category.transactionType == _type)
      .toList(growable: false);

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _changeType(String type) {
    setState(() {
      _type = type;
      _categoryId = null;
    });
  }

  void _submit() {
    final amount = parseAmountInput(_amountController.text).round();
    if (_titleController.text.trim().isEmpty || amount <= 0) {
      showInfoToast(context, 'Enter a title and a positive amount.');
      return;
    }
    final now = DateTime.now();
    final occurredAt = DateTime(
      widget.targetDate.year,
      widget.targetDate.month,
      widget.targetDate.day,
      now.hour,
      now.minute,
      now.second,
    );
    Navigator.of(context).pop(
      ManualEntryInput(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        amount: amount,
        transactionType: _type,
        categoryId: _categoryId,
        occurredAt: occurredAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    const labelStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 13, 22, 18),
        decoration: const BoxDecoration(
          color: Color(0xFFFEFEFE),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 53,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2D2D2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add an entry',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('EEEE, d MMMM').format(widget.targetDate),
                  style: const TextStyle(
                    color: Color(0xFF717171),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 17),
                ManualEntryTypeSelector(
                  value: _type,
                  onChanged: _changeType,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  title: const Text('Title', style: labelStyle),
                  hint: _type == 'expense' ? 'Coffee' : 'Salary',
                  controller: _titleController,
                  fillColor: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(14),
                  fontSize: 14,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  title: const Text('Amount', style: labelStyle),
                  hint: '0 Ar',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  fillColor: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(14),
                  fontSize: 14,
                ),
                const SizedBox(height: 14),
                ManualEntryCategoryField(
                  key: ValueKey('manual-category-$_type'),
                  categories: _categories,
                  value: _categoryId,
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  title: const Text('Note (optional)', style: labelStyle),
                  hint: 'Add a short note',
                  controller: _descriptionController,
                  fillColor: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(14),
                  fontSize: 14,
                ),
                const SizedBox(height: 19),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: FilledButton(
                    key: const Key('save-manual-entry-button'),
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: AppTheme.interactiveTextColor,
                    ),
                    child: const Text('Add entry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
