class CategoryStat {
  const CategoryStat({
    required this.name,
    required this.emoji,
    required this.amount,
  });

  final String name;
  final String emoji;
  final int amount;
}

class MonthlyStats {
  const MonthlyStats({
    required this.income,
    required this.expenses,
    required this.transactionCount,
    required this.largestExpense,
    required this.previousExpenses,
    required this.expenseCategories,
    required this.dailyExpenses,
    required this.currencyCode,
  });

  final int income;
  final int expenses;
  final int transactionCount;
  final int largestExpense;
  final int previousExpenses;
  final List<CategoryStat> expenseCategories;
  final List<int> dailyExpenses;
  final String currencyCode;

  int get balance => income - expenses;
  int get averageDailySpend =>
      dailyExpenses.isEmpty ? 0 : (expenses / dailyExpenses.length).round();
  double get expenseChange {
    if (previousExpenses == 0) return expenses == 0 ? 0 : 100;
    return (expenses - previousExpenses) / previousExpenses * 100;
  }
}
