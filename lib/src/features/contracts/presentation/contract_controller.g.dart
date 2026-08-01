// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contractsListHash() => r'db15888c9ce2c1e06192d1e35fede3f72be4556e';

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

/// See also [contractsList].
@ProviderFor(contractsList)
const contractsListProvider = ContractsListFamily();

/// See also [contractsList].
class ContractsListFamily extends Family<AsyncValue<List<Contract>>> {
  /// See also [contractsList].
  const ContractsListFamily();

  /// See also [contractsList].
  ContractsListProvider call({String? searchQuery, String? status}) {
    return ContractsListProvider(searchQuery: searchQuery, status: status);
  }

  @override
  ContractsListProvider getProviderOverride(
    covariant ContractsListProvider provider,
  ) {
    return call(searchQuery: provider.searchQuery, status: provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contractsListProvider';
}

/// See also [contractsList].
class ContractsListProvider extends FutureProvider<List<Contract>> {
  /// See also [contractsList].
  ContractsListProvider({String? searchQuery, String? status})
    : this._internal(
        (ref) => contractsList(
          ref as ContractsListRef,
          searchQuery: searchQuery,
          status: status,
        ),
        from: contractsListProvider,
        name: r'contractsListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contractsListHash,
        dependencies: ContractsListFamily._dependencies,
        allTransitiveDependencies:
            ContractsListFamily._allTransitiveDependencies,
        searchQuery: searchQuery,
        status: status,
      );

  ContractsListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
    required this.status,
  }) : super.internal();

  final String? searchQuery;
  final String? status;

  @override
  Override overrideWith(
    FutureOr<List<Contract>> Function(ContractsListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContractsListProvider._internal(
        (ref) => create(ref as ContractsListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
        status: status,
      ),
    );
  }

  @override
  FutureProviderElement<List<Contract>> createElement() {
    return _ContractsListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContractsListProvider &&
        other.searchQuery == searchQuery &&
        other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContractsListRef on FutureProviderRef<List<Contract>> {
  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;

  /// The parameter `status` of this provider.
  String? get status;
}

class _ContractsListProviderElement
    extends FutureProviderElement<List<Contract>>
    with ContractsListRef {
  _ContractsListProviderElement(super.provider);

  @override
  String? get searchQuery => (origin as ContractsListProvider).searchQuery;
  @override
  String? get status => (origin as ContractsListProvider).status;
}

String _$contractDetailsHash() => r'0dc3fd241d2a7f54ee0cf294033cb3e192ee2da1';

/// See also [contractDetails].
@ProviderFor(contractDetails)
const contractDetailsProvider = ContractDetailsFamily();

/// See also [contractDetails].
class ContractDetailsFamily extends Family<AsyncValue<Contract?>> {
  /// See also [contractDetails].
  const ContractDetailsFamily();

  /// See also [contractDetails].
  ContractDetailsProvider call(String id) {
    return ContractDetailsProvider(id);
  }

  @override
  ContractDetailsProvider getProviderOverride(
    covariant ContractDetailsProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contractDetailsProvider';
}

/// See also [contractDetails].
class ContractDetailsProvider extends AutoDisposeFutureProvider<Contract?> {
  /// See also [contractDetails].
  ContractDetailsProvider(String id)
    : this._internal(
        (ref) => contractDetails(ref as ContractDetailsRef, id),
        from: contractDetailsProvider,
        name: r'contractDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contractDetailsHash,
        dependencies: ContractDetailsFamily._dependencies,
        allTransitiveDependencies:
            ContractDetailsFamily._allTransitiveDependencies,
        id: id,
      );

  ContractDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Contract?> Function(ContractDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContractDetailsProvider._internal(
        (ref) => create(ref as ContractDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Contract?> createElement() {
    return _ContractDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContractDetailsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContractDetailsRef on AutoDisposeFutureProviderRef<Contract?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ContractDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Contract?>
    with ContractDetailsRef {
  _ContractDetailsProviderElement(super.provider);

  @override
  String get id => (origin as ContractDetailsProvider).id;
}

String _$contractStatsHash() => r'f11552065919a19ef25facdd8295a3a54be92cc1';

/// See also [contractStats].
@ProviderFor(contractStats)
final contractStatsProvider = FutureProvider<Map<String, dynamic>>.internal(
  contractStats,
  name: r'contractStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contractStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContractStatsRef = FutureProviderRef<Map<String, dynamic>>;
String _$contractInstallmentsHash() =>
    r'84a7282cc4da31fa0c962061edfa309c8592ea0d';

/// See also [contractInstallments].
@ProviderFor(contractInstallments)
const contractInstallmentsProvider = ContractInstallmentsFamily();

/// See also [contractInstallments].
class ContractInstallmentsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [contractInstallments].
  const ContractInstallmentsFamily();

  /// See also [contractInstallments].
  ContractInstallmentsProvider call(String id) {
    return ContractInstallmentsProvider(id);
  }

  @override
  ContractInstallmentsProvider getProviderOverride(
    covariant ContractInstallmentsProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contractInstallmentsProvider';
}

/// See also [contractInstallments].
class ContractInstallmentsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [contractInstallments].
  ContractInstallmentsProvider(String id)
    : this._internal(
        (ref) => contractInstallments(ref as ContractInstallmentsRef, id),
        from: contractInstallmentsProvider,
        name: r'contractInstallmentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contractInstallmentsHash,
        dependencies: ContractInstallmentsFamily._dependencies,
        allTransitiveDependencies:
            ContractInstallmentsFamily._allTransitiveDependencies,
        id: id,
      );

  ContractInstallmentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
      ContractInstallmentsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContractInstallmentsProvider._internal(
        (ref) => create(ref as ContractInstallmentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _ContractInstallmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContractInstallmentsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContractInstallmentsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ContractInstallmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with ContractInstallmentsRef {
  _ContractInstallmentsProviderElement(super.provider);

  @override
  String get id => (origin as ContractInstallmentsProvider).id;
}

String _$contractPaymentsHash() => r'7029528c2442faee2e4a0be7bc4810c0d1296122';

/// See also [contractPayments].
@ProviderFor(contractPayments)
const contractPaymentsProvider = ContractPaymentsFamily();

/// See also [contractPayments].
class ContractPaymentsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [contractPayments].
  const ContractPaymentsFamily();

  /// See also [contractPayments].
  ContractPaymentsProvider call(String id) {
    return ContractPaymentsProvider(id);
  }

  @override
  ContractPaymentsProvider getProviderOverride(
    covariant ContractPaymentsProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contractPaymentsProvider';
}

/// See also [contractPayments].
class ContractPaymentsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [contractPayments].
  ContractPaymentsProvider(String id)
    : this._internal(
        (ref) => contractPayments(ref as ContractPaymentsRef, id),
        from: contractPaymentsProvider,
        name: r'contractPaymentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contractPaymentsHash,
        dependencies: ContractPaymentsFamily._dependencies,
        allTransitiveDependencies:
            ContractPaymentsFamily._allTransitiveDependencies,
        id: id,
      );

  ContractPaymentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(ContractPaymentsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContractPaymentsProvider._internal(
        (ref) => create(ref as ContractPaymentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _ContractPaymentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContractPaymentsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContractPaymentsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ContractPaymentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with ContractPaymentsRef {
  _ContractPaymentsProviderElement(super.provider);

  @override
  String get id => (origin as ContractPaymentsProvider).id;
}

String _$contractFundingHash() => r'9a9088e27b31c341b93458a168dfbf4d9385ed0f';

/// See also [contractFunding].
@ProviderFor(contractFunding)
const contractFundingProvider = ContractFundingFamily();

/// See also [contractFunding].
class ContractFundingFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [contractFunding].
  const ContractFundingFamily();

  /// See also [contractFunding].
  ContractFundingProvider call(String id) {
    return ContractFundingProvider(id);
  }

  @override
  ContractFundingProvider getProviderOverride(
    covariant ContractFundingProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contractFundingProvider';
}

/// See also [contractFunding].
class ContractFundingProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [contractFunding].
  ContractFundingProvider(String id)
    : this._internal(
        (ref) => contractFunding(ref as ContractFundingRef, id),
        from: contractFundingProvider,
        name: r'contractFundingProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contractFundingHash,
        dependencies: ContractFundingFamily._dependencies,
        allTransitiveDependencies:
            ContractFundingFamily._allTransitiveDependencies,
        id: id,
      );

  ContractFundingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(ContractFundingRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContractFundingProvider._internal(
        (ref) => create(ref as ContractFundingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _ContractFundingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContractFundingProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContractFundingRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ContractFundingProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with ContractFundingRef {
  _ContractFundingProviderElement(super.provider);

  @override
  String get id => (origin as ContractFundingProvider).id;
}

String _$contractControllerHash() =>
    r'55d1a1ca807c2012f22b7793cfd8543d7f26aec3';

/// See also [ContractController].
@ProviderFor(ContractController)
final contractControllerProvider =
    AutoDisposeAsyncNotifierProvider<ContractController, void>.internal(
      ContractController.new,
      name: r'contractControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contractControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContractController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
