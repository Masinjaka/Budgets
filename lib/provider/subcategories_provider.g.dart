// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subcategories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subcategoriesHash() => r'aeb0f60dc313a139d12f86e3251736827aea4ea3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [subcategories].
@ProviderFor(subcategories)
const subcategoriesProvider = SubcategoriesFamily();

/// See also [subcategories].
class SubcategoriesFamily extends Family<AsyncValue<List<Subcategory>>> {
  /// See also [subcategories].
  const SubcategoriesFamily();

  /// See also [subcategories].
  SubcategoriesProvider call(
    String categoryId,
  ) {
    return SubcategoriesProvider(
      categoryId,
    );
  }

  @override
  SubcategoriesProvider getProviderOverride(
    covariant SubcategoriesProvider provider,
  ) {
    return call(
      provider.categoryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subcategoriesProvider';
}

/// See also [subcategories].
class SubcategoriesProvider
    extends AutoDisposeFutureProvider<List<Subcategory>> {
  /// See also [subcategories].
  SubcategoriesProvider(
    String categoryId,
  ) : this._internal(
          (ref) => subcategories(
            ref as SubcategoriesRef,
            categoryId,
          ),
          from: subcategoriesProvider,
          name: r'subcategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$subcategoriesHash,
          dependencies: SubcategoriesFamily._dependencies,
          allTransitiveDependencies:
              SubcategoriesFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  SubcategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    FutureOr<List<Subcategory>> Function(SubcategoriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubcategoriesProvider._internal(
        (ref) => create(ref as SubcategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Subcategory>> createElement() {
    return _SubcategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubcategoriesProvider && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubcategoriesRef on AutoDisposeFutureProviderRef<List<Subcategory>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _SubcategoriesProviderElement
    extends AutoDisposeFutureProviderElement<List<Subcategory>>
    with SubcategoriesRef {
  _SubcategoriesProviderElement(super.provider);

  @override
  String get categoryId => (origin as SubcategoriesProvider).categoryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
