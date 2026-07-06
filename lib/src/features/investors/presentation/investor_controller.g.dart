// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$investorListControllerHash() =>
    r'9301c3c38f7bb51b4d1a0656a783c737dcd9d891';

/// See also [InvestorListController].
@ProviderFor(InvestorListController)
final investorListControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      InvestorListController,
      List<Investor>
    >.internal(
      InvestorListController.new,
      name: r'investorListControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$investorListControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InvestorListController = AutoDisposeAsyncNotifier<List<Investor>>;
String _$investorDetailsControllerHash() =>
    r'2b1f8d20ee6e7d1729d2944bf810bc0a8796e7b4';

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

abstract class _$InvestorDetailsController
    extends BuildlessAutoDisposeAsyncNotifier<Investor?> {
  late final String id;

  FutureOr<Investor?> build(String id);
}

/// See also [InvestorDetailsController].
@ProviderFor(InvestorDetailsController)
const investorDetailsControllerProvider = InvestorDetailsControllerFamily();

/// See also [InvestorDetailsController].
class InvestorDetailsControllerFamily extends Family<AsyncValue<Investor?>> {
  /// See also [InvestorDetailsController].
  const InvestorDetailsControllerFamily();

  /// See also [InvestorDetailsController].
  InvestorDetailsControllerProvider call(String id) {
    return InvestorDetailsControllerProvider(id);
  }

  @override
  InvestorDetailsControllerProvider getProviderOverride(
    covariant InvestorDetailsControllerProvider provider,
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
  String? get name => r'investorDetailsControllerProvider';
}

/// See also [InvestorDetailsController].
class InvestorDetailsControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          InvestorDetailsController,
          Investor?
        > {
  /// See also [InvestorDetailsController].
  InvestorDetailsControllerProvider(String id)
    : this._internal(
        () => InvestorDetailsController()..id = id,
        from: investorDetailsControllerProvider,
        name: r'investorDetailsControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$investorDetailsControllerHash,
        dependencies: InvestorDetailsControllerFamily._dependencies,
        allTransitiveDependencies:
            InvestorDetailsControllerFamily._allTransitiveDependencies,
        id: id,
      );

  InvestorDetailsControllerProvider._internal(
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
  FutureOr<Investor?> runNotifierBuild(
    covariant InvestorDetailsController notifier,
  ) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(InvestorDetailsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: InvestorDetailsControllerProvider._internal(
        () => create()..id = id,
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
  AutoDisposeAsyncNotifierProviderElement<InvestorDetailsController, Investor?>
  createElement() {
    return _InvestorDetailsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvestorDetailsControllerProvider && other.id == id;
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
mixin InvestorDetailsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<Investor?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _InvestorDetailsControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          InvestorDetailsController,
          Investor?
        >
    with InvestorDetailsControllerRef {
  _InvestorDetailsControllerProviderElement(super.provider);

  @override
  String get id => (origin as InvestorDetailsControllerProvider).id;
}

String _$investorTransactionsControllerHash() =>
    r'c616ce564cab9b9aedc6131ba406612784f77a2d';

abstract class _$InvestorTransactionsController
    extends BuildlessAutoDisposeAsyncNotifier<List<InvestorTransaction>> {
  late final String investorId;

  FutureOr<List<InvestorTransaction>> build(String investorId);
}

/// See also [InvestorTransactionsController].
@ProviderFor(InvestorTransactionsController)
const investorTransactionsControllerProvider =
    InvestorTransactionsControllerFamily();

/// See also [InvestorTransactionsController].
class InvestorTransactionsControllerFamily
    extends Family<AsyncValue<List<InvestorTransaction>>> {
  /// See also [InvestorTransactionsController].
  const InvestorTransactionsControllerFamily();

  /// See also [InvestorTransactionsController].
  InvestorTransactionsControllerProvider call(String investorId) {
    return InvestorTransactionsControllerProvider(investorId);
  }

  @override
  InvestorTransactionsControllerProvider getProviderOverride(
    covariant InvestorTransactionsControllerProvider provider,
  ) {
    return call(provider.investorId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'investorTransactionsControllerProvider';
}

/// See also [InvestorTransactionsController].
class InvestorTransactionsControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          InvestorTransactionsController,
          List<InvestorTransaction>
        > {
  /// See also [InvestorTransactionsController].
  InvestorTransactionsControllerProvider(String investorId)
    : this._internal(
        () => InvestorTransactionsController()..investorId = investorId,
        from: investorTransactionsControllerProvider,
        name: r'investorTransactionsControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$investorTransactionsControllerHash,
        dependencies: InvestorTransactionsControllerFamily._dependencies,
        allTransitiveDependencies:
            InvestorTransactionsControllerFamily._allTransitiveDependencies,
        investorId: investorId,
      );

  InvestorTransactionsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.investorId,
  }) : super.internal();

  final String investorId;

  @override
  FutureOr<List<InvestorTransaction>> runNotifierBuild(
    covariant InvestorTransactionsController notifier,
  ) {
    return notifier.build(investorId);
  }

  @override
  Override overrideWith(InvestorTransactionsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: InvestorTransactionsControllerProvider._internal(
        () => create()..investorId = investorId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        investorId: investorId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    InvestorTransactionsController,
    List<InvestorTransaction>
  >
  createElement() {
    return _InvestorTransactionsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvestorTransactionsControllerProvider &&
        other.investorId == investorId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, investorId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InvestorTransactionsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<InvestorTransaction>> {
  /// The parameter `investorId` of this provider.
  String get investorId;
}

class _InvestorTransactionsControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          InvestorTransactionsController,
          List<InvestorTransaction>
        >
    with InvestorTransactionsControllerRef {
  _InvestorTransactionsControllerProviderElement(super.provider);

  @override
  String get investorId =>
      (origin as InvestorTransactionsControllerProvider).investorId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
