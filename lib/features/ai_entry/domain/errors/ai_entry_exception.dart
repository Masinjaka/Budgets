class AiEntryException implements Exception {
  const AiEntryException({
    required this.code,
    required this.message,
    this.status,
    this.provider,
    this.model,
    this.billingTier,
  });

  final String code;
  final String message;
  final int? status;
  final String? provider;
  final String? model;
  final String? billingTier;

  @override
  String toString() => message;
}
