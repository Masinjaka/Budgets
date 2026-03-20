import 'package:budgets/features/transactions/presentation/modules/transaction_module.dart';
import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/categories/domain/providers/filter_provider.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_filter_category_chips.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_filter_category_skeleton.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_filter_date_field.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionFilterPage extends ConsumerStatefulWidget {
  const TransactionFilterPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionFilterPageState();
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
        title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text('Filtrer',
                style:
                    TextStyle(fontWeight: FontWeight.w900, fontSize: 19.5.sp))),
        actions: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.close, size: 21.sp)))
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filtrer par catégorie',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15.5.sp)),
                SizedBox(height: 3.h),
                switch (asyncCategories) {
                  AsyncData(:final value) => TransactionFilterCategoryChips(
                      categories: value,
                      selectedCategories: _finalCategories,
                      onSelectionChanged: (cats) =>
                          setState(() => _finalCategories = cats),
                    ),
                  AsyncError(:final error) => Text('error: $error'),
                  _ => const TransactionFilterCategorySkeleton(),
                },
                SizedBox(height: 3.h),
                Text('Filtrer par date',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15.5.sp)),
                SizedBox(height: 3.h),
                SizedBox(
                  height: 6.h,
                  child: Row(
                    children: [
                      Expanded(
                          child: TransactionFilterDateField(
                              hint: 'De',
                              controller: _fromDate,
                              onTap: () => _pickDate(isFrom: true))),
                      SizedBox(width: 2.w),
                      Expanded(
                          child: TransactionFilterDateField(
                              hint: 'A',
                              controller: _toDate,
                              onTap: () => _pickDate(isFrom: false))),
                      if (_fromDate.text.isNotEmpty || _toDate.text.isNotEmpty)
                        IconButton(
                            onPressed: () => setState(() {
                                  _fromDate.clear();
                                  _toDate.clear();
                                  ref.read(dateRangeProvider.notifier).clear();
                                }),
                            icon: const Icon(Icons.clear)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.w),
        child: CustomButton(
          text: 'Appliquer les filtres',
          isLoading: _isLoading,
          onPressed: () async {
            setState(() => _isLoading = true);
            final ok = _module.filterTransaction(ref, _finalCategories,
                _fromDate.text.trim(), _toDate.text.trim(), context);
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
          if (_toDate.text.isEmpty ||
              picked.toLocal().isAfter(DateTime.parse(_toDate.text))) {
            _toDate.text = '${DateTime.now().toLocal()}'.split(' ')[0];
          }
        } else {
          _toDate.text = '${picked.toLocal()}'.split(' ')[0];
          if (_fromDate.text.isEmpty ||
              DateTime.parse(_fromDate.text).isAfter(picked.toLocal())) {
            _fromDate.text = '${_initialDateTime?.toLocal()}'.split(' ')[0];
          }
        }
      });
    }
  }
}
