class Category {
  final String? id;
  final String? name;
  final String? emoji;
  final String? color; // Added nullable color attribute

  Category({
    this.id,
    this.name,
    this.emoji,
    this.color,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String?,
      name: map['name'] as String?,
      emoji: map['emoji'] as String?,
      color: map['color'] as String?, // Added color mapping
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? emoji,
    String? color, // Added color to copyWith
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color, // Added color to copyWith
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color, // Added color to toMap
    };
  }
}