class PendingImageUpload {
  const PendingImageUpload({
    required this.id,
    required this.localPath,
    required this.storageBucket,
    required this.storagePath,
    required this.table,
    required this.rowId,
    required this.column,
    this.rowIdColumn = 'id',
    required this.createdAt,
  });

  final String id;
  final String localPath;
  final String storageBucket;
  final String storagePath;
  final String table;
  final String rowId;
  final String column;
  final String rowIdColumn;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'localPath': localPath,
        'storageBucket': storageBucket,
        'storagePath': storagePath,
        'table': table,
        'rowId': rowId,
        'column': column,
        'rowIdColumn': rowIdColumn,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PendingImageUpload.fromJson(Map<String, dynamic> json) {
    return PendingImageUpload(
      id: json['id'] as String,
      localPath: json['localPath'] as String,
      storageBucket: json['storageBucket'] as String,
      storagePath: json['storagePath'] as String,
      table: json['table'] as String,
      rowId: json['rowId'] as String,
      column: json['column'] as String,
      rowIdColumn: json['rowIdColumn'] as String? ?? 'id',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
