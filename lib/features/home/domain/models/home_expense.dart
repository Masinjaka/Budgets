enum HomeExpenseKind { food, shopping }

class HomeExpense {
  const HomeExpense({
    required this.title,
    required this.category,
    required this.amount,
    required this.kind,
  });

  final String title;
  final String category;
  final String amount;
  final HomeExpenseKind kind;
}
