import 'package:budgets/core/theme.dart';
import 'package:budgets/pages/categories/module/categori_module.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:budgets/model/category_model.dart' as cat;

class AddCategoryPage extends ConsumerStatefulWidget {
  const AddCategoryPage({super.key, this.category});
  final cat.Category? category;

  @override
  ConsumerState<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends ConsumerState<AddCategoryPage> {
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _emoticonController = TextEditingController();
  String? _selectedEmoji;
  Color? _selectedColor;
  final CategoryModule _categoryModule = CategoryModule();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isDeleting = false;

  void _showEmojiPicker(BuildContext context) async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: Container(
          height: 55.h,
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
            border: const Border(
              top: BorderSide(color: AppTheme.borderColorDark),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
            child: EmojiPicker(
              config: Config(
                searchViewConfig: SearchViewConfig(
                  backgroundColor: AppTheme.backgroundDark,
                  buttonIconColor: Colors.white,
                  hintText: 'Rechercher un emoji',
                  hintTextStyle: TextStyle(
                    fontSize: 15.sp,
                    color: const Color.fromARGB(255, 126, 127, 129),
                    fontWeight: FontWeight.w600,
                  ),
                  inputTextStyle: TextStyle(
                    fontSize: 15.sp,
                    color: const Color.fromARGB(255, 126, 127, 129),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                categoryViewConfig: CategoryViewConfig(
                  backgroundColor: AppTheme.secondaryDark,
                  tabBarHeight: 7.h,
                  iconColorSelected: Colors.white,
                  backspaceColor: Colors.white,
                  indicatorColor: Colors.white,
                ),
                emojiViewConfig: EmojiViewConfig(
                  gridPadding: EdgeInsets.symmetric(horizontal: 2.w),
                  buttonMode: ButtonMode.CUPERTINO,
                  columns: 5,
                  backgroundColor: AppTheme.backgroundDark,
                  emojiSizeMax: 20.sp,
                ),
                bottomActionBarConfig: BottomActionBarConfig(
                  customBottomActionBar: (config, state, showSearchView) {
                    return Container(
                      height: 5.h,
                      decoration: const BoxDecoration(
                        color: AppTheme.secondaryDark,
                        border: Border(
                          top: BorderSide(color: AppTheme.borderColorDark),
                        ),
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => showSearchView(),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {},
                                color: const Color.fromARGB(255, 126, 127, 129),
                              ),
                              Text(
                                'Rechercher',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color:
                                      const Color.fromARGB(255, 126, 127, 129),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  buttonColor: AppTheme.borderColorDark,
                  backgroundColor: AppTheme.backgroundDark,
                  showBackspaceButton: false,
                ),
              ),
              onEmojiSelected: (category, emoji) async {
                Navigator.pop(sheetCtx);

                await Future.delayed(const Duration(milliseconds: 100));
                setState(() {
                  _selectedEmoji = emoji.emoji;
                  _emoticonController.text = _selectedEmoji == null
                      ? 'Choisis un emoji pour ta catégorie'
                      : 'Choisir un autre emoji';
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _isEditing = true;
      _categoryNameController.text = widget.category!.name!;
      _selectedEmoji = widget.category!.emoji!;
      _selectedColor = Color(int.parse(widget.category!.color!, radix: 16));
    }
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _emoticonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier la categorie' : 'Créer une catégorie',
          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _form(context),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  backgroundColor: Colors.white,
                  text: _isEditing ? 'Modifier' : 'Ajouter',
                  onPressed: () {
                    setState(() => _isLoading = true);
                    if (_isEditing) {
                      _categoryModule
                          .editCategory(
                            ref,
                            id: widget.category!.id!,
                            name: _categoryNameController.text.trim(),
                            emoji: _selectedEmoji,
                            color: _selectedColor == null
                                ? Colors.teal.value32bit.toRadixString(16)
                                : _selectedColor!.value32bit.toRadixString(16),
                            context: context,
                            formKey: _formKey,
                          )
                          .whenComplete(
                              () => setState(() => _isLoading = false));
                    } else {
                      _categoryModule
                          .addCategory(
                            ref,
                            name: _categoryNameController.text.trim(),
                            emoji: _selectedEmoji,
                            color: _selectedColor == null
                                ? Colors.teal.value32bit.toRadixString(16)
                                : _selectedColor!.value32bit.toRadixString(16),
                            context: context,
                            formKey: _formKey,
                          )
                          .whenComplete(
                              () => setState(() => _isLoading = false));
                    }
                  },
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _form(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryDark,
                      borderRadius: BorderRadius.circular(5.w),
                      border: Border.all(
                        color: AppTheme.borderColorDark,
                      ),
                    ),
                    child: CustomTextField(
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 2.w,
                        children: [
                          const Icon(
                            Icons.edit,
                          ),
                          Text(
                            'Nom',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5.sp,
                            ),
                          ),
                        ],
                      ),
                      hint: 'Entre le nom de ta catégorie',
                      controller: _categoryNameController,
                      validator: const {
                        'type': 'required',
                        'error': 'Le nom de la catégorie est requis',
                      },
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryDark,
                      borderRadius: BorderRadius.circular(5.w),
                      border: Border.all(
                        color: AppTheme.borderColorDark,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.w),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 2.h, top: 2.h, bottom: 2.h),
                              child: CustomTextField(
                                title: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 2.w,
                                  children: [
                                    const Icon(
                                      Icons.emoji_emotions,
                                    ),
                                    Text(
                                      'Emoji',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15.5.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                hint: 'Choisis un emoji pour ta catégorie',
                                controller: _emoticonController,
                                isReadOnly: true,
                                onTap: () {
                                  _showEmojiPicker(context);
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                _showEmojiPicker(context);
                              },
                              child: Padding(
                                padding: EdgeInsets.all(4.w),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: _selectedColor ?? Colors.teal,
                                      border: Border.all(
                                        color: AppTheme.borderColorDark,
                                      ),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(
                                      _selectedEmoji ?? '',
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryDark,
                      borderRadius: BorderRadius.circular(5.w),
                      border: Border.all(
                        color: AppTheme.borderColorDark,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 2.h,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 2.w,
                              children: [
                                const Icon(
                                  Icons.color_lens,
                                ),
                                Text(
                                  "Choisis la couleur de fond de ta catégorie",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15.5.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.h),
                          child: Center(
                            child: ColorPicker(
                              color: _selectedColor ?? Colors.teal,
                              onColorChanged: (Color color) {
                                // String colortest = color.value32bit.toRadixString(16);
                                // int colorInt = int.parse(colortest, radix: 16);
                                // debugPrint('Selected color: $colortest');
                                setState(() => _selectedColor = color);
                              },
                              pickersEnabled: const <ColorPickerType, bool>{
                                ColorPickerType.wheel: true,
                                ColorPickerType.accent: false,
                                ColorPickerType.primary: false,
                                ColorPickerType.both: true,
                                ColorPickerType.custom: true,
                                ColorPickerType.bw: false,
                              },
                              wheelDiameter: 200,
                              wheelWidth: 16,
                              wheelHasBorder: false,
                              enableShadesSelection: false,
                              columnSpacing: 3.h,
                              wheelSquarePadding: 2.w,
                              pickerTypeLabels: const <ColorPickerType, String>{
                                ColorPickerType.wheel: 'Personnalisé',
                                ColorPickerType.accent: 'Accent',
                                ColorPickerType.primary: 'Primaire',
                                ColorPickerType.both: 'Basique',
                                ColorPickerType.custom: 'Personnalisé',
                                ColorPickerType.bw: 'N&B',
                              },
                              pickerTypeTextStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  if (widget.category != null)
                    GestureDetector(
                      onTap: () async {
                        setState(() => _isDeleting = true);
                        // Handle delete category
                        await _categoryModule.deleteCategory(
                          ref,
                          widget.category!,
                          context,
                        );
                        setState(() => _isDeleting = false);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryDark,
                          borderRadius: BorderRadius.circular(5.w),
                          border: Border.all(
                            color: AppTheme.borderColorDark,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 2.w,
                              children: [
                                const Icon(
                                  Icons.delete_forever_outlined,
                                ),
                                Text(
                                  'Supprimer la catégorie',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (_isDeleting)
                              SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
