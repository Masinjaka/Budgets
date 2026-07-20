class EnvelopeCategory {
  const EnvelopeCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });

  factory EnvelopeCategory.fromJson(Map<String, dynamic> json) {
    return EnvelopeCategory(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Other',
      emoji: (json['emoji'] as String?) ?? '🧾',
      color: (json['color'] as String?) ?? 'FF9E9E9E',
    );
  }

  final String id;
  final String name;
  final String emoji;
  final String color;
}
