import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/features/envelopes/domain/models/envelope.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_card.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_empty_state.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class EnvelopeListPanel extends StatefulWidget {
  const EnvelopeListPanel({
    required this.envelopes,
    required this.onDelete,
    this.displayCurrency,
    this.targetEnvelopeId,
    super.key,
  });

  final List<Envelope> envelopes;
  final ValueChanged<String> onDelete;
  final CurrencyState? displayCurrency;
  final String? targetEnvelopeId;

  @override
  State<EnvelopeListPanel> createState() => _EnvelopeListPanelState();
}

class _EnvelopeListPanelState extends State<EnvelopeListPanel> {
  final _targetKey = GlobalKey();
  bool _didReveal = false;

  @override
  void didUpdateWidget(covariant EnvelopeListPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetEnvelopeId != widget.targetEnvelopeId) {
      _didReveal = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _scheduleReveal();
    return Container(
      constraints: const BoxConstraints(minHeight: 205),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.monthlyEnvelopes,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          if (widget.envelopes.isEmpty)
            const EnvelopeEmptyState()
          else
            for (var index = 0; index < widget.envelopes.length; index++) ...[
              KeyedSubtree(
                key: Key('envelope-${widget.envelopes[index].id}'),
                child: EnvelopeCard(
                  key: widget.envelopes[index].id == widget.targetEnvelopeId
                      ? _targetKey
                      : null,
                  envelope: widget.envelopes[index],
                  onDelete: () => widget.onDelete(widget.envelopes[index].id),
                  displayCurrency: widget.displayCurrency,
                ),
              ),
              if (index < widget.envelopes.length - 1)
                const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  void _scheduleReveal() {
    final targetId = widget.targetEnvelopeId;
    if (_didReveal ||
        targetId == null ||
        !widget.envelopes.any((envelope) => envelope.id == targetId)) {
      return;
    }
    _didReveal = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _targetKey.currentContext;
      if (!mounted || target == null) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
    });
  }
}
