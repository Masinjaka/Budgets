import 'dart:io';
import '../../domain/interfaces/profile_repository.dart';
import '../datasources/supabase_profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseProfileDataSource dataSource;
  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<String> uploadProfileImage({required File file, required String userId}) async {
    return await dataSource.uploadToStorage(file: file, userId: userId);
  }

  @override
  Future<void> saveProfilePhotoUrl({required String userId, required String photoUrl}) async{
    return await dataSource.updateUserProfilePhoto(userId: userId, photoUrl: photoUrl);
  }
}
