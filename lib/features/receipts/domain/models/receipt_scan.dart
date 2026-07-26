class ReceiptScan {
  const ReceiptScan({
    required this.id,
    required this.storagePaths,
    required this.mimeTypes,
    required this.signedUrls,
    required this.status,
    required this.createdAt,
    this.errorMessage,
  });

  final String id;
  final List<String> storagePaths;
  final List<String> mimeTypes;
  final List<String> signedUrls;
  final String status;
  final DateTime createdAt;
  final String? errorMessage;

  bool get isProcessed => status == 'processed';
  bool get isFailed => status == 'failed';
  int get pageCount => storagePaths.length;
}
