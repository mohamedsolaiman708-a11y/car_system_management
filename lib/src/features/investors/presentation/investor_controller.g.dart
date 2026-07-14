// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$investorProjectionsHash() =>
    r'2131202075c5ddc3b60953676c1eb39cf8fdc165';

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

/// See also [investorProjections].
@ProviderFor(investorProjections)
const investorProjectionsProvider = InvestorProjectionsFamily();

/// See also [investorProjections].
class InvestorProjectionsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [investorProjections].
  const InvestorProjectionsFamily();

  /// See also [investorProjections].
  InvestorProjectionsProvider call(String investorId) {
    return InvestorProjectionsProvider(investorId);
  }

  @override
  InvestorProjectionsProvider getProviderOverride(
    covariant InvestorProjectionsProvider provider,
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
  String? get name => r'investorProjectionsProvider';
}

/// See also [investorProjections].
class InvestorProjectionsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [investorProjections].
  InvestorProjectionsProvider(String investorId)
    : this._internal(
        (ref) => investorProjections(ref as InvestorProjectionsRef, investorId),
        from: investorProjectionsProvider,
        name: r'investorProjectionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$investorProjectionsHash,
        dependencies: InvestorProjectionsFamily._dependencies,
        allTransitiveDependencies:
            InvestorProjectionsFamily._allTransitiveDependencies,
        investorId: investorId,
      );

  InvestorProjectionsProvider._internal(
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
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
      InvestorProjectionsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InvestorProjectionsProvider._internal(
        (ref) => create(ref as InvestorProjectionsRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _InvestorProjectionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvestorProjectionsProvider &&
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
mixin InvestorProjectionsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `investorId` of this provider.
  String get investorId;
}

class _InvestorProjectionsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with InvestorProjectionsRef {
  _InvestorProjectionsProviderElement(super.provider);

  @override
  String get investorId => (origin as InvestorProjectionsProvider).investorId;
}

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
    r'eec48056a516347b0447ed9d2bb980fbecde0a7c';

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
    r'8e8449767e8be728eb4a1bd27789e6c986c38661';

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

String _$pendingInvestorsControllerHash() =>
    r'adea416bee2b861baa26f74da1c2a467a8139c48';

/// See also [PendingInvestorsController].
@ProviderFor(PendingInvestorsController)
final pendingInvestorsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      PendingInvestorsController,
      List<Map<String, dynamic>>
    >.internal(
      PendingInvestorsController.new,
      name: r'pendingInvestorsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingInvestorsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PendingInvestorsController =
    AutoDisposeAsyncNotifier<List<Map<String, dynamic>>>;
String _$investorFundedContractsControllerHash() =>
    r'2f47786fdad744cd0206923149d417e89d12783c';

abstract class _$InvestorFundedContractsController
    extends BuildlessAutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  late final String investorId;

  FutureOr<List<Map<String, dynamic>>> build(String investorId);
}

/// See also [InvestorFundedContractsController].
@ProviderFor(InvestorFundedContractsController)
const investorFundedContractsControllerProvider =
    InvestorFundedContractsControllerFamily();

/// See also [InvestorFundedContractsController].
class InvestorFundedContractsControllerFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [InvestorFundedContractsController].
  const InvestorFundedContractsControllerFamily();

  /// See also [InvestorFundedContractsController].
  InvestorFundedContractsControllerProvider call(String investorId) {
    return InvestorFundedContractsControllerProvider(investorId);
  }

  @override
  InvestorFundedContractsControllerProvider getProviderOverride(
    covariant InvestorFundedContractsControllerProvider provider,
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
  String? get name => r'investorFundedContractsControllerProvider';
}

/// See also [InvestorFundedContractsController].
class InvestorFundedContractsControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          InvestorFundedContractsController,
          List<Map<String, dynamic>>
        > {
  /// See also [InvestorFundedContractsController].
  InvestorFundedContractsControllerProvider(String investorId)
    : this._internal(
        () => InvestorFundedContractsController()..investorId = investorId,
        from: investorFundedContractsControllerProvider,
        name: r'investorFundedContractsControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$investorFundedContractsControllerHash,
        dependencies: InvestorFundedContractsControllerFamily._dependencies,
        allTransitiveDependencies:
            InvestorFundedContractsControllerFamily._allTransitiveDependencies,
        investorId: investorId,
      );

  InvestorFundedContractsControllerProvider._internal(
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
  FutureOr<List<Map<String, dynamic>>> runNotifierBuild(
    covariant InvestorFundedContractsController notifier,
  ) {
    return notifier.build(investorId);
  }

  @override
  Override overrideWith(InvestorFundedContractsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: InvestorFundedContractsControllerProvider._internal(
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
    InvestorFundedContractsController,
    List<Map<String, dynamic>>
  >
  createElement() {
    return _InvestorFundedContractsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvestorFundedContractsControllerProvider &&
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
mixin InvestorFundedContractsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `investorId` of this provider.
  String get investorId;
}

class _InvestorFundedContractsControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          InvestorFundedContractsController,
          List<Map<String, dynamic>>
        >
    with InvestorFundedContractsControllerRef {
  _InvestorFundedContractsControllerProviderElement(super.provider);

  @override
  String get investorId =>
      (origin as InvestorFundedContractsControllerProvider).investorId;
}

String _$investorDocumentsControllerHash() =>
    r'f0a582924da09915bea2a1441a349f9b6ab65b73';

abstract class _$InvestorDocumentsController
    extends BuildlessAutoDisposeAsyncNotifier<List<AppDocument>> {
  late final String investorId;

  FutureOr<List<AppDocument>> build(String investorId);
}

/// See also [InvestorDocumentsController].
@ProviderFor(InvestorDocumentsController)
const investorDocumentsControllerProvider = InvestorDocumentsControllerFamily();

/// See also [InvestorDocumentsController].
class InvestorDocumentsControllerFamily
    extends Family<AsyncValue<List<AppDocument>>> {
  /// See also [InvestorDocumentsController].
  const InvestorDocumentsControllerFamily();

  /// See also [InvestorDocumentsController].
  InvestorDocumentsControllerProvider call(String investorId) {
    return InvestorDocumentsControllerProvider(investorId);
  }

  @override
  InvestorDocumentsControllerProvider getProviderOverride(
    covariant InvestorDocumentsControllerProvider provider,
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
  String? get name => r'investorDocumentsControllerProvider';
}

/// See also [InvestorDocumentsController].
class InvestorDocumentsControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          InvestorDocumentsController,
          List<AppDocument>
        > {
  /// See also [InvestorDocumentsController].
  InvestorDocumentsControllerProvider(String investorId)
    : this._internal(
        () => InvestorDocumentsController()..investorId = investorId,
        from: investorDocumentsControllerProvider,
        name: r'investorDocumentsControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$investorDocumentsControllerHash,
        dependencies: InvestorDocumentsControllerFamily._dependencies,
        allTransitiveDependencies:
            InvestorDocumentsControllerFamily._allTransitiveDependencies,
        investorId: investorId,
      );

  InvestorDocumentsControllerProvider._internal(
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
  FutureOr<List<AppDocument>> runNotifierBuild(
    covariant InvestorDocumentsController notifier,
  ) {
    return notifier.build(investorId);
  }

  @override
  Override overrideWith(InvestorDocumentsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: InvestorDocumentsControllerProvider._internal(
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
    InvestorDocumentsController,
    List<AppDocument>
  >
  createElement() {
    return _InvestorDocumentsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvestorDocumentsControllerProvider &&
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
mixin InvestorDocumentsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<AppDocument>> {
  /// The parameter `investorId` of this provider.
  String get investorId;
}

class _InvestorDocumentsControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          InvestorDocumentsController,
          List<AppDocument>
        >
    with InvestorDocumentsControllerRef {
  _InvestorDocumentsControllerProviderElement(super.provider);

  @override
  String get investorId =>
      (origin as InvestorDocumentsControllerProvider).investorId;
}

String _$withdrawalRequestsControllerHash() =>
    r'717baa369956b15bbbaf15d5eb3de792fe478ae1';

abstract class _$WithdrawalRequestsController
    extends BuildlessAutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  late final String? investorId;
  late final String? status;

  FutureOr<List<Map<String, dynamic>>> build({
    String? investorId,
    String? status,
  });
}

/// See also [WithdrawalRequestsController].
@ProviderFor(WithdrawalRequestsController)
const withdrawalRequestsControllerProvider =
    WithdrawalRequestsControllerFamily();

/// See also [WithdrawalRequestsController].
class WithdrawalRequestsControllerFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [WithdrawalRequestsController].
  const WithdrawalRequestsControllerFamily();

  /// See also [WithdrawalRequestsController].
  WithdrawalRequestsControllerProvider call({
    String? investorId,
    String? status,
  }) {
    return WithdrawalRequestsControllerProvider(
      investorId: investorId,
      status: status,
    );
  }

  @override
  WithdrawalRequestsControllerProvider getProviderOverride(
    covariant WithdrawalRequestsControllerProvider provider,
  ) {
    return call(investorId: provider.investorId, status: provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'withdrawalRequestsControllerProvider';
}

/// See also [WithdrawalRequestsController].
class WithdrawalRequestsControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          WithdrawalRequestsController,
          List<Map<String, dynamic>>
        > {
  /// See also [WithdrawalRequestsController].
  WithdrawalRequestsControllerProvider({String? investorId, String? status})
    : this._internal(
        () => WithdrawalRequestsController()
          ..investorId = investorId
          ..status = status,
        from: withdrawalRequestsControllerProvider,
        name: r'withdrawalRequestsControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$withdrawalRequestsControllerHash,
        dependencies: WithdrawalRequestsControllerFamily._dependencies,
        allTransitiveDependencies:
            WithdrawalRequestsControllerFamily._allTransitiveDependencies,
        investorId: investorId,
        status: status,
      );

  WithdrawalRequestsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.investorId,
    required this.status,
  }) : super.internal();

  final String? investorId;
  final String? status;

  @override
  FutureOr<List<Map<String, dynamic>>> runNotifierBuild(
    covariant WithdrawalRequestsController notifier,
  ) {
    return notifier.build(investorId: investorId, status: status);
  }

  @override
  Override overrideWith(WithdrawalRequestsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WithdrawalRequestsControllerProvider._internal(
        () => create()
          ..investorId = investorId
          ..status = status,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        investorId: investorId,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    WithdrawalRequestsController,
    List<Map<String, dynamic>>
  >
  createElement() {
    return _WithdrawalRequestsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WithdrawalRequestsControllerProvider &&
        other.investorId == investorId &&
        other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, investorId.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WithdrawalRequestsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `investorId` of this provider.
  String? get investorId;

  /// The parameter `status` of this provider.
  String? get status;
}

class _WithdrawalRequestsControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          WithdrawalRequestsController,
          List<Map<String, dynamic>>
        >
    with WithdrawalRequestsControllerRef {
  _WithdrawalRequestsControllerProviderElement(super.provider);

  @override
  String? get investorId =>
      (origin as WithdrawalRequestsControllerProvider).investorId;
  @override
  String? get status => (origin as WithdrawalRequestsControllerProvider).status;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
