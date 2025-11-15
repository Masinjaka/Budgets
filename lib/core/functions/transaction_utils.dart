import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/model/category_model.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Utility class for transaction-related operations
class TransactionUtils {
  
  /// Initialize French locale for date formatting
  static Future<void> initializeFrenchLocale() async {
    await initializeDateFormatting('fr', null);
  }

  /// Groups transactions by date and formats the date strings
  static Map<String, List<Expense>> groupTransactionsByDate(
    List<Expense> transactions,
    bool localeInitialized,
  ) {
    final Map<String, List<Expense>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final transaction in transactions) {
      if (transaction.date == null) continue;

      final transactionDate = DateTime(
        transaction.date!.year,
        transaction.date!.month,
        transaction.date!.day,
      );

      String dateKey;
      if (transactionDate.isAtSameMomentAs(today)) {
        dateKey = "Aujourd'hui";
      } else if (transactionDate.isAtSameMomentAs(yesterday)) {
        dateKey = "Hier";
      } else {
        // Use French formatting if locale is initialized, otherwise use default
        if (localeInitialized) {
          dateKey = DateFormat('dd MMMM yyyy', 'fr').format(transaction.date!);
        } else {
          dateKey = DateFormat('dd MMMM yyyy').format(transaction.date!);
        }
      }

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }

    // Sort each group by time (most recent first)
    grouped.forEach((key, value) {
      value.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    });

    return grouped;
  }

  /// Filters transactions based on search text and selected categories
  static List<Expense> filterTransactions(
    List<Expense> transactions,
    String searchText,
    List<Category> selectedCategories,
  ) {
    List<Expense> filteredTransactions = transactions;

    // Filter by search text
    final normalizedSearchText = searchText.toLowerCase().trim();
    if (normalizedSearchText.isNotEmpty) {
      filteredTransactions = filteredTransactions.where((transaction) {
        final description = transaction.description?.toLowerCase() ?? '';
        final title = transaction.title?.toLowerCase() ?? '';
        final categoryName = transaction.category?.name?.toLowerCase() ?? '';
        
        return description.contains(normalizedSearchText) ||
               title.contains(normalizedSearchText) ||
               categoryName.contains(normalizedSearchText);
      }).toList();
    }

    // Filter by selected categories
    if (selectedCategories.isNotEmpty) {
      final selectedCategoryIds = selectedCategories
          .map((cat) => cat.id)
          .where((id) => id != null)
          .toSet();
      
      filteredTransactions = filteredTransactions.where((transaction) {
        return transaction.category?.id != null &&
               selectedCategoryIds.contains(transaction.category!.id);
      }).toList();
    }

    return filteredTransactions;
  }

  /// Extracts unique categories from transactions
  static List<Category> extractCategoriesFromTransactions(List<Expense> transactions) {
    final Set<String> seenCategoryIds = {};
    final List<Category> categories = [];

    for (final transaction in transactions) {
      final category = transaction.category;
      if (category != null && 
          category.id != null && 
          !seenCategoryIds.contains(category.id)) {
        seenCategoryIds.add(category.id!);
        categories.add(category);
      }
    }

    // Sort categories alphabetically
    categories.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    return categories;
  }

  /// Filters transactions by transaction type
  static List<Expense> filterByTransactionType(
    List<Expense> transactions,
    TransactionType type,
  ) {
    return transactions.where((transaction) => 
      transaction.transactionType == type
    ).toList();
  }
}
