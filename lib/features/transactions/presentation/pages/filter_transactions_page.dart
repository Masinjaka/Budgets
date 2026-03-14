import 'dart:math';

import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/transactions/presentation/modules/transaction_module.dart';
import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/categories/domain/providers/filter_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionFilterPage extends ConsumerStatefulWidget {
  const TransactionFilterPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransactionFilterPageState();
}

class _TransactionFilterPageState extends ConsumerState<TransactionFilterPage> {
  bool _isLoading = false;
  final _module = TransactionModule();
  DateTime? _initialDateTime;
  List<String> _finalCategories = [];
  final _fromDate = TextEditingController();
  final _toDate = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialDateTime = _module.getUserCreationDate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _finalCategories = ref.read(selectedCategoriesProvider);
      final dateRange = ref.read(dateRangeProvider);
      if (dateRange != null) {
        _fromDate.text = '${dateRange.start.toLocal()}'.split(' ')[0];
        _toDate.text = '${dateRange.end.toLocal()}'.split(' ')[0];
      }
    });
  }

  @override
  void dispose() {
    _fromDate.dispose();
    _toDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Padding(padding: EdgeInsets.symmetric(horizontal: 4.w), child: Text('Filtrer', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19.5.sp))),
        actions: [Padding(padding: EdgeInsets.symmetric(horizontal: 4.w), child: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.close, size: 21.sp)))],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(left: 7.w, right: 7.w, top: 5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filtrer par catégorie', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5.sp)),
                SizedBox(height: 3.h),
                switch (asyncCategories) {
                  AsyncData(:final value) => _FilterCategoryChips(
                      categories: value,
                      selectedCategories: _finalCategories,
                      onSelectionChanged: (cats) => setState(() => _finalCategories = cats),
                    ),
                  AsyncError(:final error) => Text('error: $error'),
                  _ => _CategorySkeleton(),
                },
                SizedBox(height: 3.h),
                Text('Filtrer par date', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5.sp)),
                SizedBox(height: 3.h),
                SizedBox(
                  height: 6.h,
                  child: Row(
                    children: [
                      Expanded(child: _DateField(hint: 'De', controller: _fromDate, onTap: () => _pickDate(isFrom: true))),
                      SizedBox(width: 2.w),
                      Expanded(child: _DateField(hint: 'A', controller: _toDate, onTap: () => _pickDate(isFrom: false))),
                      if (_fromDate.text.isNotEmpty || _toDate.text.isNotEmpty)
                        IconButton(onPressed: () => setState(() { _fromDate.clear(); _toDate.clear(); ref.read(dateRangeProvider.notifier).clear(); }), icon: const Icon(Icons.clear)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.w),
        child: CustomButton(
          text: 'Appliquer les filtres',
          isLoading: _isLoading,
          onPressed: () async {
            setState(() => _isLoading = true);
            final ok = _module.filterTransaction(ref, _finalCategories, _fromDate.text.trim(), _toDate.text.trim(), context);
            setState(() => _isLoading = false);
            if (ok) context.pop();
          },
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _initialDateTime : DateTime.now(),
      firstDate: _initialDateTime ?? DateTime(2025, 6),
      lastDate: DateTime.now(),
      cancelText: 'Annuler',
      helpText: 'Choisis une date',
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate.text = '${picked.toLocal()}'.split(' ')[0];
          if (_toDate.text.isEmpty || picked.toLocal().isAfter(DateTime.parse(_toDate.text))) {
            _toDate.text = '${DateTime.now().toLocal()}'.split(' ')[0];
          }
        } else {
          _toDate.text = '${picked.toLocal()}'.split(' ')[0];
          if (_fromDate.text.isEmpty || DateTime.parse(_fromDate.text).isAfter(picked.toLocal())) {
            _fromDate.text = '${_initialDateTime?.toLocal()}'.split(' ')[0];
          }
        }
      });
    }
  }
}

class _FilterCategoryChips extends StatefulWidget {
  final List<Category> categories;
  final List<String> selectedCategories;
  final void Function(List<String>) onSelectionChanged;

  const _FilterCategoryChips({required this.categories, required this.selectedCategories, required this.onSelectionChanged});

  @override
  State<_FilterCategoryChips> createState() => _FilterCategoryChipsState();
}

class _FilterCategoryChipsState extends State<_FilterCategoryChips> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 2.5.w,
      children: widget.categories.map((e) {
        final isSelected = _selected.contains(e.name);
        return InkWell(
          onTap: () {
            setState(() {
              isSelected ? _selected.remove(e.name) : _selected.add(e.name ?? 'Inconnu');
              widget.onSelectionChanged(List.from(_selected));
            });
          },
          splashColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(5.w),
            ),
            child: Text(e.name ?? 'Inconnu', style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15.sp)),
          ),
        );
      }).toList(),
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 2.5.w,
      children: List.generate(7, (i) => Container(
        width: 10.w + Random().nextDouble() * (40.w - 10.w),
        height: 4.2.h,
        margin: EdgeInsets.only(right: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
        decoration: BoxDecoration(color: const Color.fromARGB(255, 216, 216, 216), borderRadius: BorderRadius.circular(5.w)),
      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: const Duration(seconds: 1), color: Colors.white)),
    );
  }
}

class _DateField extends StatelessWidget {
  final String? hint;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _DateField({required this.hint, required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      controller: controller,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w), borderSide: const BorderSide(color: Colors.transparent, width: 1.8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w), borderSide: const BorderSide(color: Colors.black, width: 1.8)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w), borderSide: const BorderSide(color: Color.fromARGB(255, 252, 154, 147), width: 1.8)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w), borderSide: const BorderSide(color: Colors.black, width: 1.8)),
        hintText: hint,
        suffixIcon: Icon(Icons.calendar_month_outlined, color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
    );
  }
}
