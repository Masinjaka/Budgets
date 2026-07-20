class AiQuota {
  const AiQuota({
    required this.plan,
    required this.unlimited,
    required this.remaining,
  });

  factory AiQuota.fromJson(Map<String, dynamic> json) {
    return AiQuota(
      plan: (json['plan'] as String?) ?? 'free',
      unlimited: (json['unlimited'] as bool?) ?? false,
      remaining: (json['remaining'] as num?)?.toInt(),
    );
  }

  final String plan;
  final bool unlimited;
  final int? remaining;
}
