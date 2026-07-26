import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/receipts/domain/models/receipt_scan.dart';
import 'package:budgets/features/receipts/presentation/widgets/receipt_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class ReceiptGalleryCard extends StatelessWidget {
  const ReceiptGalleryCard({
    required this.scan,
    required this.onTap,
    required this.onDelete,
    required this.isDeleting,
    super.key,
  });

  final ReceiptScan scan;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ReceiptThumbnail(
                    url: scan.signedUrls.first,
                    mimeType: scan.mimeTypes.first,
                  ),
                  if (scan.pageCount > 1)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _PageCount(count: scan.pageCount),
                    ),
                  Positioned(
                    top: 3,
                    right: 3,
                    child: IconButton.filledTonal(
                      key: const Key('receipt-delete-button'),
                      onPressed: isDeleting ? null : onDelete,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        foregroundColor: Theme.of(context).colorScheme.error,
                        disabledBackgroundColor: Theme.of(context).cardColor,
                        disabledForegroundColor: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: .55),
                      ),
                      icon: isDeleting
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline_rounded, size: 20),
                      tooltip: context.l10n.deleteReceipt,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
              child: Text(
                DateFormat(
                  'd MMM yyyy, HH:mm',
                  Localizations.localeOf(context).toLanguageTag(),
                ).format(scan.createdAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppTypography.supporting,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageCount extends StatelessWidget {
  const _PageCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: const ShapeDecoration(
          color: Color(0xFFD7EBDD),
          shape: StadiumBorder(),
        ),
        child: Text(
          context.l10n.pageCount(count),
          style: const TextStyle(
            color: Colors.black,
            fontSize: AppTypography.caption,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
