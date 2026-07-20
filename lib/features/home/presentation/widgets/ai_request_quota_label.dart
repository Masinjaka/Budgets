import 'package:flutter/material.dart';

class AiRequestQuotaLabel extends StatelessWidget {
  const AiRequestQuotaLabel({
    required this.remaining,
    this.unlimited = false,
    super.key,
  });

  final int? remaining;
  final bool unlimited;

  @override
  Widget build(BuildContext context) {
    final count = remaining;
    return SizedBox(
      height: 24,
      child: unlimited
          ? const Center(
              child: Text(
                'Unlimited AI requests with Drala Plus',
                key: Key('ai-request-quota-label'),
                style: TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : count == null
              ? const SizedBox.shrink()
              : Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'You have '),
                        TextSpan(
                          text: '$count',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(text: ' AI requests remaining today'),
                      ],
                    ),
                    key: const Key('ai-request-quota-label'),
                    style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
    );
  }
}
