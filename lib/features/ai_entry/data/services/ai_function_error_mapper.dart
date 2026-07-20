import 'package:budgets/features/ai_entry/domain/errors/ai_entry_exception.dart';
import 'package:budgets/features/home/domain/errors/insufficient_funds_exception.dart';
import 'package:budgets/features/home/domain/errors/wallet_selection_required_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiFunctionErrorMapper {
  const AiFunctionErrorMapper._();

  static Exception map(FunctionException exception) {
    final details = _record(exception.details);
    final error = _record(details['error']);
    final model = _record(error['model']);
    final errorDetails = _record(error['details']);
    if (error['code'] == 'wallet_consent_required' ||
        error['code'] == 'wallet_selection_required') {
      return WalletSelectionRequiredException(
        requiredAmount: (errorDetails['required_amount'] as num? ?? 0).round(),
        availableAmount: (errorDetails['available_amount'] as num?)?.round(),
        requestId: errorDetails['request_id'] as String?,
        extraction: _record(errorDetails['extraction']),
      );
    }
    if (error['code'] == 'insufficient_funds') {
      return InsufficientFundsException(
        requiredAmount: (errorDetails['required_amount'] as num? ?? 0).round(),
        availableAmount:
            (errorDetails['available_amount'] as num? ?? 0).round(),
      );
    }
    return AiEntryException(
      code: (error['code'] as String?) ?? 'function_error',
      message: (error['message'] as String?) ??
          'The AI service could not process this message.',
      status: exception.status,
      provider: model['provider'] as String?,
      model: model['name'] as String?,
      billingTier: model['billing_tier'] as String?,
    );
  }

  static Map<String, dynamic> _record(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
}
