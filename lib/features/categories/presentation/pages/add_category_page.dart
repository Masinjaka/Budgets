import 'package:budgets/core/ui/glass_flexible_space.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/constants.dart';
import 'package:budgets/features/planning/data/datasources/goal_datasource.dart'
    as goal_datasource;
import 'package:go_router/go_router.dart';
import 'package:budgets/features/categories/presentation/modules/categori_module.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart'
    as cat;

class AddCategoryPage extends ConsumerStatefulWidget {
  final cat.Category? category;
  final String transactionType;

  const AddCategoryPage({
    super.key,
    this.category,
    this.transactionType = 'expense',
  });

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
  bool _isSavingsCategoryWithGoals = false;

  // Get transaction type from widget
  TransactionType get transactionType =>
      TransactionType.fromValue(widget.transactionType) ??
      TransactionType.expense;

  /// Check if this is the savings category and user has goals
  bool get _isSavingsCategory =>
      widget.category != null &&
      widget.category!.name == SystemCategories.savingsCategoryName;

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
          height: 440,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: EmojiPicker(
              config: Config(
                searchViewConfig: SearchViewConfig(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  buttonIconColor:
                      Theme.of(context).iconTheme.color ?? Colors.white,
                  hintText: 'Rechercher un emoji',
                  hintTextStyle: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                  inputTextStyle: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                categoryViewConfig: CategoryViewConfig(
                  backgroundColor: Theme.of(context).cardColor,
                  tabBarHeight: 56,
                  iconColorSelected:
                      Theme.of(context).iconTheme.color ?? Colors.white,
                  backspaceColor:
                      Theme.of(context).iconTheme.color ?? Colors.white,
                  indicatorColor: Theme.of(context).primaryColor,
                ),
                emojiViewConfig: EmojiViewConfig(
                  gridPadding: EdgeInsets.symmetric(horizontal: 8),
                  buttonMode: ButtonMode.CUPERTINO,
                  columns: 5,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  emojiSizeMax: 20,
                ),
                bottomActionBarConfig: BottomActionBarConfig(
                  customBottomActionBar: (config, state, showSearchView) {
                    return Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
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
                                color: Theme.of(context).hintColor,
                              ),
                              Text(
                                'Rechercher',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  buttonColor: Theme.of(context).dividerColor,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

      // Check if this is savings category with goals
      if (_isSavingsCategory) {
        _checkForGoals();
      }
    }
  }

  Future<void> _checkForGoals() async {
    final hasGoals = await goal_datasource.hasAnyGoals();
    if (mounted) {
      setState(() {
        _isSavingsCategoryWithGoals = hasGoals;
      });
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isSavingsCategoryWithGoals
              ? 'Catégorie système'
              : (_isEditing ? 'Modifier la catégorie' : 'Créer une catégorie'),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassFlexibleSpace(),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isSavingsCategoryWithGoals
          ? _buildSavingsCategoryInfo(context)
          : _form(context),
      bottomNavigationBar: _isSavingsCategoryWithGoals
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(32, 0, 32, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        backgroundColor: Theme.of(context).primaryColor,
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
                                      ? Colors.teal.value.toRadixString(16)
                                      : _selectedColor!.value.toRadixString(16),
                                  // transactionType: widget.category?.transactionType ?? transactionType,
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
                                      ? Colors.teal.value.toRadixString(16)
                                      : _selectedColor!.value.toRadixString(16),
                                  transactionType: transactionType,
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

  /// Build info screen for savings category that cannot be edited
  Widget _buildSavingsCategoryInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SizedBox(height: 112),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(int.parse(
                        widget.category?.color ??
                            SystemCategories.savingsCategoryColor,
                        radix: 16)),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.category?.emoji ??
                        SystemCategories.savingsCategoryEmoji,
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  widget.category?.name ?? SystemCategories.savingsCategoryName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cette catégorie est utilisée automatiquement pour vos contributions aux objectifs d\'épargne. Elle ne peut pas être modifiée ou supprimée tant que vous avez des objectifs.',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _form(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 96), // Top padding for glass effect
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomTextField(
                    title: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        const Icon(
                          Icons.edit,
                        ),
                        Text(
                          'Nom',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15.5,
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
                SizedBox(height: 24),
                Container(
                  height: 112,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: 16, top: 16, bottom: 16),
                            child: CustomTextField(
                              title: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                  const Icon(
                                    Icons.emoji_emotions,
                                  ),
                                  Text(
                                    'Emoji',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15.5,
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
                              padding: EdgeInsets.all(16),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: _selectedColor ?? Colors.teal,
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Text(
                                    _selectedEmoji ?? '',
                                    style: TextStyle(
                                      fontSize: 22,
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
                SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              const Icon(
                                Icons.color_lens,
                              ),
                              Text(
                                "Choisis la couleur de fond de ta catégorie",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Center(
                          child: ColorPicker(
                            color: _selectedColor ?? Colors.teal,
                            onColorChanged: (Color color) {
                              // String colortest = color.value.toRadixString(16);
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
                            columnSpacing: 24,
                            wheelSquarePadding: 8,
                            pickerTypeLabels: const <ColorPickerType, String>{
                              ColorPickerType.wheel: 'Personnalisé',
                              ColorPickerType.accent: 'Accent',
                              ColorPickerType.primary: 'Primaire',
                              ColorPickerType.both: 'Basique',
                              ColorPickerType.custom: 'Personnalisé',
                              ColorPickerType.bw: 'N&B',
                            },
                            pickerTypeTextStyle: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
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
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              const Icon(
                                Icons.delete_forever_outlined,
                              ),
                              Text(
                                'Supprimer la catégorie',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (_isDeleting)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).iconTheme.color,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ), // Padding
    ); // GestureDetector
  }
}
