class Envelope {
  const Envelope({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.emoji,
    required this.color,
    required this.amount,
    required this.spent,
    required this.currencyCode,
  });

  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final String emoji;
  final String color;
  final int amount;
  final int spent;
  final String currencyCode;

  int get remaining => amount - spent;
  double get progress => amount == 0 ? 0 : spent / amount;
  bool get isExceeded => spent > amount;

  Envelope copyWith({int? spent}) => Envelope(
        id: id,
        name: name,
        categoryId: categoryId,
        categoryName: categoryName,
        emoji: emoji,
        color: color,
        amount: amount,
        spent: spent ?? this.spent,
        currencyCode: currencyCode,
      );
}
