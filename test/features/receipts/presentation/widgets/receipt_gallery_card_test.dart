import 'package:budgets/core/theme.dart';
import 'package:budgets/features/receipts/domain/models/receipt_scan.dart';
import 'package:budgets/features/receipts/presentation/widgets/receipt_gallery_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the neutral surface and danger color for delete',
      (tester) async {
    var deleted = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 320,
            child: ReceiptGalleryCard(
              scan: ReceiptScan(
                id: 'receipt',
                storagePaths: const ['receipt.pdf'],
                mimeTypes: const ['application/pdf'],
                signedUrls: const ['https://example.test/receipt.pdf'],
                status: 'processed',
                createdAt: DateTime(2026, 7, 25),
              ),
              onTap: () {},
              onDelete: () => deleted = true,
              isDeleting: false,
            ),
          ),
        ),
      ),
    );

    final button = tester.widget<IconButton>(
      find.byKey(const Key('receipt-delete-button')),
    );
    expect(
      button.style?.backgroundColor?.resolve({}),
      AppTheme.neutralSurface,
    );
    expect(
      button.style?.foregroundColor?.resolve({}),
      AppTheme.dangerColor,
    );

    await tester.tap(find.byKey(const Key('receipt-delete-button')));
    expect(deleted, isTrue);
  });
}
