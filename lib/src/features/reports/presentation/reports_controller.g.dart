// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$revenueReportHash() => r'818c6579ac92a0cba220f9f90313448822ae3046';

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

/// See also [revenueReport].
@ProviderFor(revenueReport)
const revenueReportProvider = RevenueReportFamily();

/// See also [revenueReport].
class RevenueReportFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [revenueReport].
  const RevenueReportFamily();

  /// See also [revenueReport].
  RevenueReportProvider call({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
  }) {
    return RevenueReportProvider(
      startDate: startDate,
      endDate: endDate,
      investorId: investorId,
    );
  }

  @override
  RevenueReportProvider getProviderOverride(
    covariant RevenueReportProvider provider,
  ) {
    return call(
      startDate: provider.startDate,
      endDate: provider.endDate,
      investorId: provider.investorId,
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
  String? get name => r'revenueReportProvider';
}

/// See also [revenueReport].
class RevenueReportProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [revenueReport].
  RevenueReportProvider({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
  }) : this._internal(
         (ref) => revenueReport(
           ref as RevenueReportRef,
           startDate: startDate,
           endDate: endDate,
           investorId: investorId,
         ),
         from: revenueReportProvider,
         name: r'revenueReportProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$revenueReportHash,
         dependencies: RevenueReportFamily._dependencies,
         allTransitiveDependencies:
             RevenueReportFamily._allTransitiveDependencies,
         startDate: startDate,
         endDate: endDate,
         investorId: investorId,
       );

  RevenueReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
    required this.investorId,
  }) : super.internal();

  final DateTime startDate;
  final DateTime endDate;
  final String? investorId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(RevenueReportRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RevenueReportProvider._internal(
        (ref) => create(ref as RevenueReportRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
        investorId: investorId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _RevenueReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RevenueReportProvider &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.investorId == investorId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, investorId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RevenueReportRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;

  /// The parameter `investorId` of this provider.
  String? get investorId;
}

class _RevenueReportProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with RevenueReportRef {
  _RevenueReportProviderElement(super.provider);

  @override
  DateTime get startDate => (origin as RevenueReportProvider).startDate;
  @override
  DateTime get endDate => (origin as RevenueReportProvider).endDate;
  @override
  String? get investorId => (origin as RevenueReportProvider).investorId;
}

String _$profitReportHash() => r'4adb1b4910920a27df11aa486b6eb96ceb1ecb97';

/// See also [profitReport].
@ProviderFor(profitReport)
const profitReportProvider = ProfitReportFamily();

/// See also [profitReport].
class ProfitReportFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [profitReport].
  const ProfitReportFamily();

  /// See also [profitReport].
  ProfitReportProvider call({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
    String? customerId,
  }) {
    return ProfitReportProvider(
      startDate: startDate,
      endDate: endDate,
      investorId: investorId,
      customerId: customerId,
    );
  }

  @override
  ProfitReportProvider getProviderOverride(
    covariant ProfitReportProvider provider,
  ) {
    return call(
      startDate: provider.startDate,
      endDate: provider.endDate,
      investorId: provider.investorId,
      customerId: provider.customerId,
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
  String? get name => r'profitReportProvider';
}

/// See also [profitReport].
class ProfitReportProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [profitReport].
  ProfitReportProvider({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
    String? customerId,
  }) : this._internal(
         (ref) => profitReport(
           ref as ProfitReportRef,
           startDate: startDate,
           endDate: endDate,
           investorId: investorId,
           customerId: customerId,
         ),
         from: profitReportProvider,
         name: r'profitReportProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$profitReportHash,
         dependencies: ProfitReportFamily._dependencies,
         allTransitiveDependencies:
             ProfitReportFamily._allTransitiveDependencies,
         startDate: startDate,
         endDate: endDate,
         investorId: investorId,
         customerId: customerId,
       );

  ProfitReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
    required this.investorId,
    required this.customerId,
  }) : super.internal();

  final DateTime startDate;
  final DateTime endDate;
  final String? investorId;
  final String? customerId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(ProfitReportRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfitReportProvider._internal(
        (ref) => create(ref as ProfitReportRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
        investorId: investorId,
        customerId: customerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _ProfitReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfitReportProvider &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.investorId == investorId &&
        other.customerId == customerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, investorId.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfitReportRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;

  /// The parameter `investorId` of this provider.
  String? get investorId;

  /// The parameter `customerId` of this provider.
  String? get customerId;
}

class _ProfitReportProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with ProfitReportRef {
  _ProfitReportProviderElement(super.provider);

  @override
  DateTime get startDate => (origin as ProfitReportProvider).startDate;
  @override
  DateTime get endDate => (origin as ProfitReportProvider).endDate;
  @override
  String? get investorId => (origin as ProfitReportProvider).investorId;
  @override
  String? get customerId => (origin as ProfitReportProvider).customerId;
}

String _$trialBalanceHash() => r'bb6208e2be0b7fdaeb904327c2abd7d5d3997142';

/// See also [trialBalance].
@ProviderFor(trialBalance)
final trialBalanceProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      trialBalance,
      name: r'trialBalanceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trialBalanceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrialBalanceRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$cashFlowReportHash() => r'c0a17edffa1a52b9f8a36c047550d2d7015b2118';

/// See also [cashFlowReport].
@ProviderFor(cashFlowReport)
const cashFlowReportProvider = CashFlowReportFamily();

/// See also [cashFlowReport].
class CashFlowReportFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [cashFlowReport].
  const CashFlowReportFamily();

  /// See also [cashFlowReport].
  CashFlowReportProvider call({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
  }) {
    return CashFlowReportProvider(
      startDate: startDate,
      endDate: endDate,
      investorId: investorId,
    );
  }

  @override
  CashFlowReportProvider getProviderOverride(
    covariant CashFlowReportProvider provider,
  ) {
    return call(
      startDate: provider.startDate,
      endDate: provider.endDate,
      investorId: provider.investorId,
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
  String? get name => r'cashFlowReportProvider';
}

/// See also [cashFlowReport].
class CashFlowReportProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [cashFlowReport].
  CashFlowReportProvider({
    required DateTime startDate,
    required DateTime endDate,
    String? investorId,
  }) : this._internal(
         (ref) => cashFlowReport(
           ref as CashFlowReportRef,
           startDate: startDate,
           endDate: endDate,
           investorId: investorId,
         ),
         from: cashFlowReportProvider,
         name: r'cashFlowReportProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$cashFlowReportHash,
         dependencies: CashFlowReportFamily._dependencies,
         allTransitiveDependencies:
             CashFlowReportFamily._allTransitiveDependencies,
         startDate: startDate,
         endDate: endDate,
         investorId: investorId,
       );

  CashFlowReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
    required this.investorId,
  }) : super.internal();

  final DateTime startDate;
  final DateTime endDate;
  final String? investorId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(CashFlowReportRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CashFlowReportProvider._internal(
        (ref) => create(ref as CashFlowReportRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
        investorId: investorId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _CashFlowReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CashFlowReportProvider &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.investorId == investorId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, investorId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CashFlowReportRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;

  /// The parameter `investorId` of this provider.
  String? get investorId;
}

class _CashFlowReportProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with CashFlowReportRef {
  _CashFlowReportProviderElement(super.provider);

  @override
  DateTime get startDate => (origin as CashFlowReportProvider).startDate;
  @override
  DateTime get endDate => (origin as CashFlowReportProvider).endDate;
  @override
  String? get investorId => (origin as CashFlowReportProvider).investorId;
}

String _$overdueReportHash() => r'0644a7a45c05b66f9638e390f4c41122b6dea27b';

/// See also [overdueReport].
@ProviderFor(overdueReport)
final overdueReportProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      overdueReport,
      name: r'overdueReportProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$overdueReportHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OverdueReportRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$investorsPerformanceHash() =>
    r'4ff4581efc70bdca532b9c8351415edaa8d05375';

/// See also [investorsPerformance].
@ProviderFor(investorsPerformance)
final investorsPerformanceProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      investorsPerformance,
      name: r'investorsPerformanceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$investorsPerformanceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InvestorsPerformanceRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$contractsSummaryHash() => r'df2b655b063b92df3ca8a622daeb7636171e6adb';

/// See also [contractsSummary].
@ProviderFor(contractsSummary)
final contractsSummaryProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      contractsSummary,
      name: r'contractsSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contractsSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContractsSummaryRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$collectionsReportHash() => r'b0d9b9404b40892d3c0e1a406b3ec91b605ac059';

/// See also [collectionsReport].
@ProviderFor(collectionsReport)
const collectionsReportProvider = CollectionsReportFamily();

/// See also [collectionsReport].
class CollectionsReportFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [collectionsReport].
  const CollectionsReportFamily();

  /// See also [collectionsReport].
  CollectionsReportProvider call({
    required DateTime startDate,
    required DateTime endDate,
    String? customerId,
  }) {
    return CollectionsReportProvider(
      startDate: startDate,
      endDate: endDate,
      customerId: customerId,
    );
  }

  @override
  CollectionsReportProvider getProviderOverride(
    covariant CollectionsReportProvider provider,
  ) {
    return call(
      startDate: provider.startDate,
      endDate: provider.endDate,
      customerId: provider.customerId,
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
  String? get name => r'collectionsReportProvider';
}

/// See also [collectionsReport].
class CollectionsReportProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [collectionsReport].
  CollectionsReportProvider({
    required DateTime startDate,
    required DateTime endDate,
    String? customerId,
  }) : this._internal(
         (ref) => collectionsReport(
           ref as CollectionsReportRef,
           startDate: startDate,
           endDate: endDate,
           customerId: customerId,
         ),
         from: collectionsReportProvider,
         name: r'collectionsReportProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$collectionsReportHash,
         dependencies: CollectionsReportFamily._dependencies,
         allTransitiveDependencies:
             CollectionsReportFamily._allTransitiveDependencies,
         startDate: startDate,
         endDate: endDate,
         customerId: customerId,
       );

  CollectionsReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
    required this.customerId,
  }) : super.internal();

  final DateTime startDate;
  final DateTime endDate;
  final String? customerId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(CollectionsReportRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CollectionsReportProvider._internal(
        (ref) => create(ref as CollectionsReportRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
        customerId: customerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _CollectionsReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionsReportProvider &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.customerId == customerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CollectionsReportRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;

  /// The parameter `customerId` of this provider.
  String? get customerId;
}

class _CollectionsReportProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with CollectionsReportRef {
  _CollectionsReportProviderElement(super.provider);

  @override
  DateTime get startDate => (origin as CollectionsReportProvider).startDate;
  @override
  DateTime get endDate => (origin as CollectionsReportProvider).endDate;
  @override
  String? get customerId => (origin as CollectionsReportProvider).customerId;
}

String _$reportFiltersControllerHash() =>
    r'cf8d9498bc2f02b59bafe24f52b349f83e575655';

/// See also [ReportFiltersController].
@ProviderFor(ReportFiltersController)
final reportFiltersControllerProvider =
    AutoDisposeNotifierProvider<
      ReportFiltersController,
      Map<String, String?>
    >.internal(
      ReportFiltersController.new,
      name: r'reportFiltersControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reportFiltersControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReportFiltersController = AutoDisposeNotifier<Map<String, String?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
