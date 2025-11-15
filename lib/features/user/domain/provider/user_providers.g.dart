// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userDataSourceHash() => r'995a1acec3a2cdb9bda16f62cc9e4f27750b05df';

/// See also [userDataSource].
@ProviderFor(userDataSource)
final userDataSourceProvider =
    AutoDisposeProvider<SupabaseUserDataSource>.internal(
  userDataSource,
  name: r'userDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserDataSourceRef = AutoDisposeProviderRef<SupabaseUserDataSource>;
String _$userRepositoryHash() => r'ac37b85479d29d663e33b2f2b788d3e51cefd162';

/// See also [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = AutoDisposeProvider<UserRepositoryImpl>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = AutoDisposeProviderRef<UserRepositoryImpl>;
String _$userModelHash() => r'c9ee86ebf367d4a995f337827cb8f5a09cb7fa64';

/// See also [userModel].
@ProviderFor(userModel)
final userModelProvider = AutoDisposeFutureProvider<UserModel?>.internal(
  userModel,
  name: r'userModelProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserModelRef = AutoDisposeFutureProviderRef<UserModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
