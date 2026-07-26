import 'package:budgets/features/receipts/domain/models/receipt_scan.dart';
import 'package:budgets/features/receipts/domain/repositories/receipt_repository.dart';
import 'package:flutter/foundation.dart';

class ReceiptGalleryViewModel extends ChangeNotifier {
  ReceiptGalleryViewModel(this._repository);

  final ReceiptRepository _repository;
  List<ReceiptScan> _scans = const [];
  bool _isLoading = false;
  String? _deletingId;

  List<ReceiptScan> get scans => _scans;
  bool get isLoading => _isLoading;
  String? get deletingId => _deletingId;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _scans = List.unmodifiable(await _repository.scans());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(ReceiptScan scan) async {
    if (_deletingId != null) return;
    _deletingId = scan.id;
    notifyListeners();
    try {
      await _repository.delete(scan.id);
      _scans = List.unmodifiable(
        _scans.where((item) => item.id != scan.id),
      );
    } finally {
      _deletingId = null;
      notifyListeners();
    }
  }
}
