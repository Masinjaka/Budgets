import 'package:budgets/features/ai_entry/data/repositories/preview_ai_entry_repository.dart';
import 'package:budgets/features/ai_entry/data/repositories/supabase_ai_entry_repository.dart';
import 'package:budgets/features/ai_entry/data/services/ai_entry_service.dart';
import 'package:budgets/features/ai_entry/data/services/manual_entry_service.dart';
import 'package:budgets/features/ai_entry/domain/repositories/ai_entry_repository.dart';
import 'package:budgets/features/receipts/data/repositories/supabase_receipt_repository.dart';
import 'package:budgets/features/receipts/data/services/receipt_query_service.dart';
import 'package:budgets/features/receipts/data/services/receipt_ai_service.dart';
import 'package:budgets/features/receipts/data/services/receipt_storage_service.dart';
import 'package:budgets/features/receipts/domain/repositories/receipt_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepositories {
  const HomeRepositories({required this.ai, this.receipts});

  final AiEntryRepository ai;
  final ReceiptRepository? receipts;
}

class HomeRepositoryFactory {
  const HomeRepositoryFactory._();

  static HomeRepositories create(DateTime today) {
    try {
      final client = Supabase.instance.client;
      final aiService = AiEntryService(client);
      return HomeRepositories(
        ai: SupabaseAiEntryRepository(
          aiService,
          ManualEntryService(client),
        ),
        receipts: SupabaseReceiptRepository(
          ReceiptStorageService(client),
          ReceiptQueryService(client),
          ReceiptAiService(client),
        ),
      );
    } catch (_) {
      return HomeRepositories(ai: PreviewAiEntryRepository(today));
    }
  }
}
