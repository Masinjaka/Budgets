import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';

class AiEntryResult {
  const AiEntryResult({
    required this.entries,
    required this.message,
    required this.remaining,
    required this.provider,
    required this.model,
    required this.billingTier,
    this.plan = 'free',
    this.unlimited = false,
    this.notice,
  });

  factory AiEntryResult.fromJson(Map<String, dynamic> json) {
    final modelJson = Map<String, dynamic>.from(json['model'] as Map? ?? {});
    final rawEntries = json['entries'] as List? ?? const [];
    return AiEntryResult(
      entries: rawEntries
          .map((item) => FinanceEntry.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false),
      message: (json['message'] as String?) ?? '',
      remaining: (json['remaining'] as num?)?.toInt(),
      provider: (modelJson['provider'] as String?) ?? 'unknown',
      model: (modelJson['name'] as String?) ?? 'unknown',
      billingTier: (modelJson['billing_tier'] as String?) ?? 'unknown',
      plan: (json['plan'] as String?) ?? 'free',
      unlimited: (json['unlimited'] as bool?) ?? false,
      notice: json['notice'] as String?,
    );
  }

  final List<FinanceEntry> entries;
  final String message;
  final int? remaining;
  final String provider;
  final String model;
  final String billingTier;
  final String plan;
  final bool unlimited;
  final String? notice;
}
