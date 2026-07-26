import 'package:budgets/features/receipts/domain/models/receipt_scan.dart';
import 'package:budgets/features/receipts/presentation/widgets/receipt_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class ReceiptPreviewPage extends StatelessWidget {
  const ReceiptPreviewPage({required this.scan, super.key});

  final ReceiptScan scan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: Text(
          scan.pageCount == 1
              ? context.l10n.receipt
              : context.l10n.receiptPages(scan.pageCount),
        ),
      ),
      body: PageView.builder(
        itemCount: scan.pageCount,
        itemBuilder: (context, index) => InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: Center(
            child: ReceiptThumbnail(
              url: scan.signedUrls[index],
              mimeType: scan.mimeTypes[index],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
