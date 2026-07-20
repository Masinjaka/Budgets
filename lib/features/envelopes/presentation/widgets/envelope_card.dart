import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/envelopes/domain/models/envelope.dart';
import 'package:flutter/material.dart';

class EnvelopeCard extends StatelessWidget {
  const EnvelopeCard({
    required this.envelope,
    required this.onDelete,
    super.key,
  });

  final Envelope envelope;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final progress = envelope.progress.clamp(0.0, 1.0);
    final accent =
        envelope.isExceeded ? const Color(0xFFD84A3A) : const Color(0xFF202020);
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 16, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  shape: BoxShape.circle,
                ),
                child:
                    Text(envelope.emoji, style: const TextStyle(fontSize: 19)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      envelope.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      envelope.categoryName,
                      style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded, size: 21),
                onSelected: (_) => onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete envelope'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress,
              backgroundColor: const Color(0xFFE8E8E8),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatAmountWithCurrency(envelope.spent, envelope.currencyCode)} spent',
                style: TextStyle(
                  color: accent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'of ${formatAmountWithCurrency(envelope.amount, envelope.currencyCode)}',
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
