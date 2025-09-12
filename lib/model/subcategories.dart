class Subcategory {
  final String? id;
  final DateTime? createdAt;
  final String? name;
  final String? categoryId;

  Subcategory({
    this.id,
    this.createdAt,
    this.name,
    this.categoryId,
  });

  factory Subcategory.fromMap(Map<String, dynamic> map) {
    return Subcategory(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      name: map['name'] as String?,
      categoryId: map['category_id'] as String?,
    );
  }

  Subcategory copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? categoryId,
  }) {
    return Subcategory(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'name': name,
      'category_id': categoryId,
    };
  }
}