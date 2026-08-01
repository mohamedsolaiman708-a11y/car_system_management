// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_timeline_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contractTimelineHash() => r'b4e9db851acbbcb68de4b620cb44de199a35bf94';

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

/// See also [contractTimeline].
@ProviderFor(contractTimeline)
const contractTimelineProvider = ContractTimelineFamily();

/// See also [contractTimeline].
class ContractTimelineFamily
    extends Family<AsyncValue<List<ContractActivity>>> {
  /// See also [contractTimeline].
  const ContractTimelineFamily();

  /// See also [contractTimeline].
  ContractTimelineProvider call(String contractId) {
    return ContractTimelineProvider(contractId);
  }

  @override
  ContractTimelineProvider getProviderOverride(
    covariant ContractTimelineProvider provider,
  ) {
    return call(provider.contractId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contractTimelineProvider';
}

/// See also [contractTimeline].
class ContractTimelineProvider
    extends AutoDisposeFutureProvider<List<ContractActivity>> {
  /// See also [contractTimeline].
  ContractTimelineProvider(String contractId)
    : this._internal(
        (ref) => contractTimeline(ref as ContractTimelineRef, contractId),
        from: contractTimelineProvider,
        name: r'contractTimelineProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contractTimelineHash,
        dependencies: ContractTimelineFamily._dependencies,
        allTransitiveDependencies:
            ContractTimelineFamily._allTransitiveDependencies,
        contractId: contractId,
      );

  ContractTimelineProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contractId,
  }) : super.internal();

  final String contractId;

  @override
  Override overrideWith(
    FutureOr<List<ContractActivity>> Function(ContractTimelineRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContractTimelineProvider._internal(
        (ref) => create(ref as ContractTimelineRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contractId: contractId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ContractActivity>> createElement() {
    return _ContractTimelineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContractTimelineProvider && other.contractId == contractId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contractId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContractTimelineRef
    on AutoDisposeFutureProviderRef<List<ContractActivity>> {
  /// The parameter `contractId` of this provider.
  String get contractId;
}

class _ContractTimelineProviderElement
    extends AutoDisposeFutureProviderElement<List<ContractActivity>>
    with ContractTimelineRef {
  _ContractTimelineProviderElement(super.provider);

  @override
  String get contractId => (origin as ContractTimelineProvider).contractId;
}

String _$contractTimelineNotifierHash() =>
    r'48578e9e3bcc096a28c7654215b8c2476b2382fa';

abstract class _$ContractTimelineNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<ContractActivity>> {
  late final String contractId;

  FutureOr<List<ContractActivity>> build(String contractId);
}

/// See also [ContractTimelineNotifier].
@ProviderFor(ContractTimelineNotifier)
const contractTimelineNotifierProvider = ContractTimelineNotifierFamily();

/// See also [ContractTimelineNotifier].
class ContractTimelineNotifierFamily
    extends Family<AsyncValue<List<ContractActivity>>> {
  /// See also [ContractTimelineNotifier].
  const ContractTimelineNotifierFamily();

  /// See also [ContractTimelineNotifier].
  ContractTimelineNotifierProvider call(String contractId) {
    return ContractTimelineNotifierProvider(contractId);
  }

  @override
  ContractTimelineNotifierProvider getProviderOverride(
    covariant ContractTimelineNotifierProvider provider,
  ) {
    return call(provider.contractId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contractTimelineNotifierProvider';
}

/// See also [ContractTimelineNotifier].
class ContractTimelineNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ContractTimelineNotifier,
          List<ContractActivity>
        > {
  /// See also [ContractTimelineNotifier].
  ContractTimelineNotifierProvider(String contractId)
    : this._internal(
        () => ContractTimelineNotifier()..contractId = contractId,
        from: contractTimelineNotifierProvider,
        name: r'contractTimelineNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contractTimelineNotifierHash,
        dependencies: ContractTimelineNotifierFamily._dependencies,
        allTransitiveDependencies:
            ContractTimelineNotifierFamily._allTransitiveDependencies,
        contractId: contractId,
      );

  ContractTimelineNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contractId,
  }) : super.internal();

  final String contractId;

  @override
  FutureOr<List<ContractActivity>> runNotifierBuild(
    covariant ContractTimelineNotifier notifier,
  ) {
    return notifier.build(contractId);
  }

  @override
  Override overrideWith(ContractTimelineNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContractTimelineNotifierProvider._internal(
        () => create()..contractId = contractId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contractId: contractId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ContractTimelineNotifier,
    List<ContractActivity>
  >
  createElement() {
    return _ContractTimelineNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContractTimelineNotifierProvider &&
        other.contractId == contractId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contractId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContractTimelineNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<ContractActivity>> {
  /// The parameter `contractId` of this provider.
  String get contractId;
}

class _ContractTimelineNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ContractTimelineNotifier,
          List<ContractActivity>
        >
    with ContractTimelineNotifierRef {
  _ContractTimelineNotifierProviderElement(super.provider);

  @override
  String get contractId =>
      (origin as ContractTimelineNotifierProvider).contractId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
