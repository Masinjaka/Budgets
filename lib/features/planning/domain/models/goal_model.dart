class Goal {
  final String? id; // UUID
  final DateTime? createdAt;
  final String? userId;
  final String? name;
  final DateTime? dateAim;
  final String? goalAmount;
  final String? currentAmount;
  final String? imagePath;

  Goal({
    this.id,
    this.createdAt,
    this.userId,
    this.name,
    this.dateAim,
    this.goalAmount,
    this.currentAmount,
    this.imagePath,
  });

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      userId: map['user_id'] as String?,
      name: map['name'] as String?,
      dateAim: map['date_aim'] != null
          ? DateTime.parse(map['date_aim'] as String)
          : null,
      goalAmount: map['goal_amount'] as String?,
      currentAmount: map['current_amount'] as String?,
      imagePath: map['image_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'user_id': userId,
      'name': name,
      'date_aim': dateAim?.toIso8601String(),
      'goal_amount': goalAmount,
      'current_amount': currentAmount,
      'image_path': imagePath,
    };
  }

  Goal copyWith({
    String? id,
    DateTime? createdAt,
    String? userId,
    String? name,
    DateTime? dateAim,
    String? goalAmount,
    String? currentAmount,
    String? imagePath,
  }) {
    return Goal(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dateAim: dateAim ?? this.dateAim,
      goalAmount: goalAmount ?? this.goalAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
