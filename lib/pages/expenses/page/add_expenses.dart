import 'package:budgets/pages/expenses/module/expense_module.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:chips_input_autocomplete/chips_input_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpenseCreationPage extends ConsumerStatefulWidget {
  const ExpenseCreationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpenseCreationPageState();
}

class _ExpenseCreationPageState extends ConsumerState<ExpenseCreationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;
  final ExpenseModule _module = ExpenseModule();

  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final ChipsAutocompleteController _categorieController =
      ChipsAutocompleteController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        final categories = await _module.fetchCategories(ref);
        List<String> options = categories
            .map((category) => category.name ?? 'A_category_with_no_name')
            .toList();
        _categorieController.options = options;
        debugPrint("CATEGORIES: ${categories.length}, ${options[0]}");
      },
    );
  }

  @override
  void dispose() {
    _designationController.dispose();
    _descriptionController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildForm(),
      bottomNavigationBar: _buildAddButton(),
    );
  }

  GestureDetector _buildForm() {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(left: 7.w, right: 7.w, top: 5.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    title: 'Designation',
                    hint: 'Bazary',
                    controller: _designationController,
                    keyboardType: TextInputType.text,
                    validator: const <String, String>{"type": "required"},
                  ),
                  SizedBox(height: 1.5.h),
                  CustomTextField(
                    title: 'Description',
                    hint: 'Laoka atoandro sy hariva',
                    controller: _descriptionController,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 1.5.h),
                  CustomTextField(
                    title: 'Montant',
                    hint: '10000',
                    controller: _montantController,
                    keyboardType: TextInputType.number,
                    validator: const <String, String>{"type": "required"},
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    'Catégorie',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5.sp,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  _buildCategoryField(),
                  SizedBox(height: 1.5.h),
                  Text(
                    'Facture (facultative)',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5.sp,
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFacultativeOption(
                        title: 'Prendre une photo',
                        iconData: Icons.camera_alt_outlined,
                        onTap: null,
                      ),
                      Text(
                        'ou',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5.sp,
                        ),
                      ),
                      _buildFacultativeOption(
                        title: 'Scanner une facture',
                        iconData: Icons.document_scanner_outlined,
                        onTap: null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _buildCategoryField() {
    return SizedBox(
      width: double.infinity,
      child: ChipsInputAutocomplete(
        createCharacter: ' ',
        controller: _categorieController,
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xff72DEF6),
          deleteIconColor: Colors.black,
          labelStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.h),
            side: const BorderSide(
              color: Colors.black,
            ),
          ),
        ),
        widgetContainerDecoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(
            2.w,
          ),
        ),
        paddingInsideWidgetContainer: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 1.w,
        ),
        addChipOnSelection: true,
        decorationTextField:  InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(left: 8.0),
          hintText: 'Tapez...',
          constraints: BoxConstraints(maxWidth: 80.w),
        ),
      ),
    );
  }

  _buildFacultativeOption(
      {required String title,
      required IconData iconData,
      required void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 23.sp,
            ),
            SizedBox(
              height: 1.5.h,
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Text(
          'Ajouter un achat',
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

  Padding _buildAddButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.w),
      child: CustomButton(
        text: 'Confirmer',
        onPressed: () async {
          setState(() => _isLoading = true);

          if (_categorieController.chips.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tu dois choisir une categorie'),
              ),
            );
          } else {
            await _module.addExpense(
              _designationController.text.trim(),
              _descriptionController.text.trim(),
              _categorieController.chips[0],
              _montantController.text.trim(),
              formKey: _formKey,
              ref: ref,
              context: context,
            );
          }

          setState(() => _isLoading = false);
        },
        isLoading: _isLoading,
      ),
    );
  }
}
