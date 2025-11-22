import 'dart:math';

import 'package:budgets/core/theme.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/transactions/presentation/modules/expense_module.dart';
import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/categories/domain/providers/filter_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpenseFilterPage extends ConsumerStatefulWidget {
  const ExpenseFilterPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpenseFilterPageState();
}

class _ExpenseFilterPageState extends ConsumerState<ExpenseFilterPage> {
  bool _isLoading = false;
  final ExpenseModule _module = ExpenseModule();
  DateTime? _initialDateTime;

  List<String> _selectedCategories = [];
  List<String> _finalCategories = [];

  final TextEditingController _fromDate = TextEditingController();
  final TextEditingController _toDate = TextEditingController();

  @override
  void initState() {
    super.initState();

    // get initial date time for date filter
    _initialDateTime = _module.getUserCreationDate();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _finalCategories = ref.read(selectedCategoriesProvider);
        _selectedCategories = _finalCategories;

        final dateRange = ref.read(dateRangeProvider);

        // Fill up the date range if there are already
        if (dateRange != null) {
          _fromDate.text = '${dateRange.start.toLocal()}'.split(' ')[0];
          _toDate.text = '${dateRange.end.toLocal()}'.split(' ')[0];
        }
      },
    );
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
      appBar: _buildAppBar(context),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(left: 7.w, right: 7.w, top: 5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Filtrer par catégorie',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5.sp,
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  // Category list
                  switch (asyncCategories) {
                    AsyncData(:final value) => _buildCategories(value),
                    AsyncError(:final error) => Text('error: $error'),
                    _ => _buildCategorySkeleton(),
                  },
                  SizedBox(
                    height: 3.h,
                  ),
                  Text(
                    'Filtrer par date',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5.sp,
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  SizedBox(
                    height: 6.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildField(
                            'De',
                            _fromDate,
                            () {
                              // Perform your desired action here
                              showDatePicker(
                                context: context,
                                initialDate: _initialDateTime,
                                firstDate:
                                    _initialDateTime ?? DateTime(2025, 6),
                                lastDate: DateTime.now(),
                                cancelText: 'Annuler',
                                helpText: 'Choisis une date',
                              ).then((selectedDate) {
                                if (selectedDate != null) {
                                  setState(() {
                                    _fromDate.text = '${selectedDate.toLocal()}'
                                        .split(' ')[0];
                                    // if the end date is still empty, fill it with the current date
                                    if (_toDate.text.isEmpty ||
                                        (_toDate.text.isNotEmpty &&
                                            selectedDate.toLocal().isAfter(
                                                DateTime.parse(
                                                    _toDate.text)))) {
                                      _toDate.text =
                                          '${DateTime.now().toLocal()}'
                                              .split(' ')[0];
                                    }
                                  });
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        Expanded(
                          child: _buildField(
                            'A',
                            _toDate,
                            () {
                              // Perform your desired action here
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate:
                                    _initialDateTime ?? DateTime(2025, 6),
                                lastDate: DateTime.now(),
                                cancelText: 'Annuler',
                                helpText: 'Choisis une date',
                              ).then((selectedDate) {
                                if (selectedDate != null) {
                                  setState(() {
                                    setState(() {
                                      _toDate.text = '${selectedDate.toLocal()}'
                                          .split(' ')[0];
                                      // if the end date is still empty, fill it with the current date
                                      if (_fromDate.text.isEmpty ||
                                          (_fromDate.text.isNotEmpty &&
                                              DateTime.parse(_fromDate.text)
                                                  .isAfter(selectedDate
                                                      .toLocal()))) {
                                        _fromDate.text =
                                            '${_initialDateTime?.toLocal()}'
                                                .split(' ')[0];
                                      }
                                    });
                                  });
                                }
                              });
                            },
                          ),
                        ),
                        if (_fromDate.text.isNotEmpty ||
                            _toDate.text.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _fromDate.clear();
                                _toDate.clear();
                                ref.read(dateRangeProvider.notifier).state =
                                    null;
                              });
                            },
                            icon: const Icon(Icons.clear),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildAddButton(),
    );
  }

  Padding _buildAddButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.w),
      child: CustomButton(
        text: 'Appliquer les filtres',
        isLoading: _isLoading,
        onPressed: () async {
          setState(() => _isLoading = true);

          final hasSucceeded = _module.filterExpense(
            ref,
            _finalCategories,
            _fromDate.text.trim(),
            _toDate.text.trim(),
            context,
          );

          setState(() => _isLoading = false);

          if (hasSucceeded) context.pop();
        },
      ),
    );
  }

  TextFormField _buildField(
      String? hint, TextEditingController controller, void Function()? onTap) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      controller: controller,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.secondaryDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 1.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
          borderSide: const BorderSide(
            color: Colors.black, // Match blue stroke when focused
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 252, 154, 147),
            width: 1.8,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.8,
          ),
        ),
        hintText: hint,
        suffixIcon: const Icon(
          Icons.calendar_month_outlined,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  // Build app bar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Text(
          'Filtrer',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 19.5.sp,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.close,
                size: 21.sp,
              )),
        ),
      ],
    );
  }

  // build categories
  _buildCategories(List<Category> categories) {
    return Wrap(
      runSpacing: 2.5.w,
      children: categories.map((e) {
        bool isSelected = _finalCategories.contains(e.name);

        return InkWell(
          onTap: () {
            // Select or de-select the category
            setState(() {
              _selectedCategories.contains(e.name)
                  ? _selectedCategories.remove(e.name)
                  : _selectedCategories.add(e.name ?? 'Inconnu');

              _finalCategories = [..._selectedCategories];
            });
          },
          splashColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.symmetric(
              horizontal: 2.w,
              vertical: 2.w,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.textDark : AppTheme.secondaryDark,
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(5.w),
            ),
            child: Text(
              e.name ?? 'Inconnu',
              style: TextStyle(
                  color: isSelected ? Colors.black : AppTheme.textDark,
                  fontSize: 15.sp),
            ),
          ),
        );
      }).toList(),
    );
  }

  _buildCategorySkeleton() {
    return Wrap(
      runSpacing: 2.5.w,
      children: List.generate(
        7,
        (index) {
          return Container(
            width: 10.w + Random().nextDouble() * (40.w - 10.w),
            height: 4.2.h,
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.symmetric(
              horizontal: 2.w,
              vertical: 2.w,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 216, 216, 216),
              borderRadius: BorderRadius.circular(5.w),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .shimmer(
                duration: const Duration(seconds: 1),
                color: Colors.white,
              );
        },
      ),
    );
  }
}
