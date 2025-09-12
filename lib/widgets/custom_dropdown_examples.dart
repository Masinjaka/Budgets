// Example: Using CustomDropdown in different scenarios
// This file shows various ways the CustomDropdown widget can be used throughout the app

/*
EXAMPLE 1: Basic usage in expense creation (already implemented)
*/

/*
// In add_expenses.dart - already implemented
CustomDropdown(
  title: Text(
    'Catégorie',
    style: TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 15.5.sp,
    ),
  ),
  hint: 'Bazary',
  items: _categories,
  selectedValue: _selectedCategory,
  onChanged: (Category? category) {
    setState(() {
      _selectedCategory = category;
    });
  },
  validator: const <String, String>{"type": "required"},
  showEmojis: true,
),
*/

/*
EXAMPLE 2: Filter usage (replacement for current chips-based filter)
*/

/*
// In filter_expenses.dart - potential replacement
CustomDropdown(
  title: Text('Filtrer par catégorie'),
  hint: 'Toutes les catégories',
  items: _availableCategories,
  selectedValue: _selectedFilterCategory,
  onChanged: (Category? category) {
    setState(() {
      _selectedFilterCategory = category;
    });
    // Apply filter logic
    _applyFilter(category);
  },
  showEmojis: true,
  showColors: true,
  // No validator needed for optional filter
),
*/

/*
EXAMPLE 3: Settings page for default categories
*/

/*
// In settings page
CustomDropdown(
  title: Text('Catégorie par défaut'),
  hint: 'Sélectionner une catégorie',
  items: categories,
  selectedValue: defaultCategory,
  onChanged: (Category? category) {
    setState(() {
      defaultCategory = category;
    });
    saveDefaultCategory(category);
  },
  validator: const {"type": "required"},
  showEmojis: true,
  showColors: true,
),
*/

/*
EXAMPLE 4: Report generation category selection
*/

/*
CustomDropdown(
  title: Text('Catégorie pour le rapport'),
  hint: 'Sélectionner une catégorie',
  items: reportCategories,
  selectedValue: reportCategory,
  onChanged: (Category? category) {
    generateReport(category);
  },
  showEmojis: true,
  showColors: false, // Only show emojis for reports
),
*/

/*
EXAMPLE 5: Disabled/empty state
*/

/*
CustomDropdown(
  title: Text('Catégories archivées'),
  items: [], // Empty list
  enabled: false,
  hint: 'Aucune catégorie archivée',
  onChanged: null,
),
*/

/*
EXAMPLE 6: Form integration with multiple dropdowns
*/

/*
Form(
  key: _formKey,
  child: Column(
    children: [
      CustomDropdown(
        title: Text('Catégorie principale'),
        items: primaryCategories,
        selectedValue: selectedPrimary,
        onChanged: (category) => setState(() => selectedPrimary = category),
        validator: const {"type": "required"},
      ),
      
      SizedBox(height: 16),
      
      CustomDropdown(
        title: Text('Sous-catégorie'),
        items: getSubCategories(selectedPrimary), // Dynamic items
        selectedValue: selectedSub,
        onChanged: (category) => setState(() => selectedSub = category),
        enabled: selectedPrimary != null, // Conditional enabling
        showColors: true,
      ),
      
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process form
          }
        },
        child: Text('Valider'),
      ),
    ],
  ),
)
*/

/*
CUSTOMIZATION OPTIONS:

1. showEmojis: true/false - Display category emojis
2. showColors: true/false - Display category color indicators  
3. enabled: true/false - Enable/disable interaction
4. validator: Map<String, String> - Validation rules
5. hint: String - Placeholder text
6. selectedValue: Category? - Current selection
7. onChanged: Function(Category?) - Selection callback

THEME INTEGRATION:
- Automatically adapts to dark/light theme
- Uses AppTheme constants for consistent styling
- Responsive sizing with responsive_sizer

VALIDATION:
- Built-in "required" validation
- Custom error messages
- Form integration support

ACCESSIBILITY:
- Proper labeling with title widget
- Keyboard navigation support
- Screen reader compatible
*/
