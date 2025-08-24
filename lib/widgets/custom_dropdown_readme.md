# CustomDropdown Widget Documentation

## Overview

The `CustomDropdown` is a reusable Flutter widget designed for category selection in the Budgets app. It provides a styled dropdown that follows the app's theme system and supports both dark and light modes.

## Features

- **Theme-aware**: Automatically adapts to the app's current theme (dark/light mode)
- **Category display**: Shows categories with emojis and names (colors removed for cleaner look)
- **Natural drop animations**: Dropdown "drops down" from the text field when opening and "pulls up" into the text field when closing with faster, more intuitive animations (150ms)
- **Seamless connection**: Dropdown appears directly below text field with no top border for visual continuity
- **Dynamic border styling**: Text field corners become sharp (only bottom corners) when dropdown is open, reverses to rounded when closed
- **Consistent border thickness**: Text field border maintains same thickness whether focused or not
- **Validation**: Built-in validation support
- **Customizable**: Configurable display options for emojis
- **Responsive**: Uses responsive sizing for consistent appearance across devices
- **Click outside to close**: Automatically closes when clicking outside the dropdown

## Usage

### Basic Implementation

```dart
import 'package:budgets/widgets/custom_dropdown.dart';
import 'package:budgets/model/category_model.dart';

// In your widget state
List<Category> _categories = [];
Category? _selectedCategory;

// In your widget build method
CustomDropdown(
  title: Text(
    'Catégorie',
    style: TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 15.5.sp,
    ),
  ),
  hint: 'Choisissez une catégorie',
  items: _categories,
  selectedValue: _selectedCategory,
  onChanged: (Category? category) {
    setState(() {
      _selectedCategory = category;
    });
  },
  validator: const <String, String>{"type": "required"},
  showEmojis: true,
  showColors: true,
),
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `title` | `Widget` | ✅ | - | The label widget displayed above the dropdown |
| `hint` | `String?` | ❌ | `null` | Placeholder text when no item is selected |
| `items` | `List<Category>` | ✅ | - | List of categories to display in dropdown |
| `onChanged` | `Function(Category?)?` | ❌ | `null` | Callback when selection changes |
| `validator` | `Map<String, String>?` | ❌ | `null` | Validation rules for the dropdown |
| `selectedValue` | `Category?` | ❌ | `null` | Currently selected category |
| `enabled` | `bool` | ❌ | `true` | Whether the dropdown is interactive |
| `showEmojis` | `bool` | ❌ | `true` | Whether to display category emojis |
| `showColors` | `bool` | ❌ | `false` | Whether to display category color indicators |

### Validation

The widget supports validation using a map format:

```dart
validator: const <String, String>{
  "type": "required",
  "error": "Please select a category" // Optional custom error message
}
```

Supported validation types:
- `"required"`: Ensures a category is selected

### Styling Features

- **Dark Mode Support**: Automatically uses appropriate colors for dark/light themes
- **Category Colors**: Optional circular color indicators for each category
- **Category Emojis**: Display category emojis alongside names
- **Responsive Design**: Sizes adapt to different screen sizes using `responsive_sizer`

### Form Integration

The widget can be easily integrated into forms:

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      CustomDropdown(
        title: Text('Select Category'),
        items: categories,
        selectedValue: selectedCategory,
        onChanged: (category) => setState(() => selectedCategory = category),
        validator: const {"type": "required"},
      ),
      // Other form fields...
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process form
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

### Empty State Handling

When no categories are available, the dropdown displays:
- "Aucune catégorie disponible" message
- Disabled state to prevent interaction
- Italicized, muted text styling

## Theme Integration

The widget automatically integrates with the app's theme system:

```dart
final globalTheme = ref.watch(globalThemeProvider);
final isDarkMode = globalTheme == Brightness.dark;
```

Colors used:
- **Dark Mode**: `AppTheme.secondaryDark`, `AppTheme.textDark`, `AppTheme.borderColorDark`
- **Light Mode**: `Colors.white`, `Colors.black`, `Colors.black54`

## Dependencies

- `flutter/material.dart`
- `flutter_riverpod`
- `responsive_sizer`
- App-specific:
  - `budgets/core/theme.dart`
  - `budgets/model/category_model.dart`
  - `budgets/provider/app_theme_provider.dart`

## Best Practices

1. **Always provide a title**: Use descriptive labels for accessibility
2. **Handle empty states**: Ensure categories list is populated before display
3. **Use validation**: Implement appropriate validation for required fields
4. **Theme consistency**: The widget automatically handles theming - avoid overriding colors manually
5. **Form integration**: Use within Form widgets with proper validation handling

## Example Use Cases

1. **Expense Creation**: Select category for new expenses
2. **Filtering**: Choose categories to filter expenses/transactions
3. **Settings**: Configure default categories
4. **Reporting**: Select categories for report generation

## Migration from ChipsInputAutocomplete

If migrating from the old `ChipsInputAutocomplete` approach:

```dart
// Old approach
ChipsInputAutocomplete(
  controller: _categorieController,
  // ... other properties
)

// New approach
CustomDropdown(
  items: _categories,
  selectedValue: _selectedCategory,
  onChanged: (category) => setState(() => _selectedCategory = category),
  // ... other properties
)
```

Key differences:
- No controller needed - uses direct state management
- Single selection instead of multiple chips
- Built-in theme integration
- Category object handling instead of strings
