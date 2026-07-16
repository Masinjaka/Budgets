enum ReceiptInputSource { importedFile, scannedReceipt }

class ReceiptInputResult {
  const ReceiptInputResult({
    required this.source,
    required this.paths,
  });

  final ReceiptInputSource source;
  final List<String> paths;

  bool get isEmpty => paths.isEmpty;
}
