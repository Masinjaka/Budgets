import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/home/domain/models/receipt_input_result.dart';
import 'package:budgets/features/receipts/domain/models/receipt_scan.dart';
import 'package:budgets/features/receipts/domain/repositories/receipt_repository.dart';
import 'package:budgets/features/receipts/presentation/view_models/receipt_gallery_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads and immediately removes a deleted receipt', () async {
    final scan = ReceiptScan(
      id: 'scan-1',
      storagePaths: const ['user/scan/page-1.jpg'],
      mimeTypes: const ['image/jpeg'],
      signedUrls: const ['https://example.test/receipt'],
      status: 'processed',
      createdAt: DateTime(2026, 7, 22),
    );
    final repository = _FakeReceiptRepository([scan]);
    final viewModel = ReceiptGalleryViewModel(repository);

    await viewModel.load();
    expect(viewModel.scans, [scan]);

    await viewModel.delete(scan);
    expect(repository.deletedId, 'scan-1');
    expect(viewModel.scans, isEmpty);
    expect(viewModel.deletingId, isNull);
  });
}

class _FakeReceiptRepository implements ReceiptRepository {
  _FakeReceiptRepository(this.items);

  final List<ReceiptScan> items;
  String? deletedId;

  @override
  Future<List<ReceiptScan>> scans() async => items;

  @override
  Future<void> delete(String scanId) async => deletedId = scanId;

  @override
  Future<AiEntryResult> process(
    ReceiptInputResult input, {
    required DateTime targetDate,
    required String outputLanguage,
  }) {
    throw UnimplementedError();
  }
}
