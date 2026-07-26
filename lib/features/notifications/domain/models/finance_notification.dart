class FinanceNotification {
  const FinanceNotification({
    required this.id,
    required this.envelopeId,
    required this.envelopeName,
    required this.amount,
    required this.periodMonth,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String envelopeId;
  final String envelopeName;
  final int amount;
  final DateTime periodMonth;
  final bool isRead;
  final DateTime createdAt;

  FinanceNotification copyWith({bool? isRead}) => FinanceNotification(
        id: id,
        envelopeId: envelopeId,
        envelopeName: envelopeName,
        amount: amount,
        periodMonth: periodMonth,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  factory FinanceNotification.fromJson(Map<String, dynamic> json) {
    return FinanceNotification(
      id: json['id'] as String,
      envelopeId: json['envelope_id'] as String,
      envelopeName: json['envelope_name'] as String,
      amount: (json['amount'] as num).round(),
      periodMonth: DateTime.parse(json['period_month'] as String),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
