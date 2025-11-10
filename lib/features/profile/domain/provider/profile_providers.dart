import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_profile_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../usecases/upload_and_save_profile_photo.dart';

part 'profile_providers.g.dart';

@riverpod
SupabaseProfileDataSource profileDataSource(Ref ref) {
  final client = Supabase.instance.client;
  return SupabaseProfileDataSource(client);
}

@riverpod
ProfileRepositoryImpl profileRepository(Ref ref) {
  final ds = ref.watch(profileDataSourceProvider);
  return ProfileRepositoryImpl(ds);
}

@riverpod
UploadAndSaveProfilePhoto uploadAndSaveProfilePhoto(Ref ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return UploadAndSaveProfilePhoto(repo);
}
