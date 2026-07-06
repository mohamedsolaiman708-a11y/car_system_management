// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customersListHash() => r'620be9c8dc7dea375131f44c925b5ef0f0f1f131';

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

/// See also [customersList].
@ProviderFor(customersList)
const customersListProvider = CustomersListFamily();

/// See also [customersList].
class CustomersListFamily extends Family<AsyncValue<List<Customer>>> {
  /// See also [customersList].
  const CustomersListFamily();

  /// See also [customersList].
  CustomersListProvider call({
    String? searchQuery,
    String? status,
    String? city,
  }) {
    return CustomersListProvider(
      searchQuery: searchQuery,
      status: status,
      city: city,
    );
  }

  @override
  CustomersListProvider getProviderOverride(
    covariant CustomersListProvider provider,
  ) {
    return call(
      searchQuery: provider.searchQuery,
      status: provider.status,
      city: provider.city,
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
  String? get name => r'customersListProvider';
}

/// See also [customersList].
class CustomersListProvider extends AutoDisposeFutureProvider<List<Customer>> {
  /// See also [customersList].
  CustomersListProvider({String? searchQuery, String? status, String? city})
    : this._internal(
        (ref) => customersList(
          ref as CustomersListRef,
          searchQuery: searchQuery,
          status: status,
          city: city,
        ),
        from: customersListProvider,
        name: r'customersListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customersListHash,
        dependencies: CustomersListFamily._dependencies,
        allTransitiveDependencies:
            CustomersListFamily._allTransitiveDependencies,
        searchQuery: searchQuery,
        status: status,
        city: city,
      );

  CustomersListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
    required this.status,
    required this.city,
  }) : super.internal();

  final String? searchQuery;
  final String? status;
  final String? city;

  @override
  Override overrideWith(
    FutureOr<List<Customer>> Function(CustomersListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomersListProvider._internal(
        (ref) => create(ref as CustomersListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
        status: status,
        city: city,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Customer>> createElement() {
    return _CustomersListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomersListProvider &&
        other.searchQuery == searchQuery &&
        other.status == status &&
        other.city == city;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, city.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomersListRef on AutoDisposeFutureProviderRef<List<Customer>> {
  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;

  /// The parameter `status` of this provider.
  String? get status;

  /// The parameter `city` of this provider.
  String? get city;
}

class _CustomersListProviderElement
    extends AutoDisposeFutureProviderElement<List<Customer>>
    with CustomersListRef {
  _CustomersListProviderElement(super.provider);

  @override
  String? get searchQuery => (origin as CustomersListProvider).searchQuery;
  @override
  String? get status => (origin as CustomersListProvider).status;
  @override
  String? get city => (origin as CustomersListProvider).city;
}

String _$customerDetailsHash() => r'4d5f8ac5ea7208e5e1e0472796a9890f57912727';

/// See also [customerDetails].
@ProviderFor(customerDetails)
const customerDetailsProvider = CustomerDetailsFamily();

/// See also [customerDetails].
class CustomerDetailsFamily extends Family<AsyncValue<Customer?>> {
  /// See also [customerDetails].
  const CustomerDetailsFamily();

  /// See also [customerDetails].
  CustomerDetailsProvider call(String id) {
    return CustomerDetailsProvider(id);
  }

  @override
  CustomerDetailsProvider getProviderOverride(
    covariant CustomerDetailsProvider provider,
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
  String? get name => r'customerDetailsProvider';
}

/// See also [customerDetails].
class CustomerDetailsProvider extends AutoDisposeFutureProvider<Customer?> {
  /// See also [customerDetails].
  CustomerDetailsProvider(String id)
    : this._internal(
        (ref) => customerDetails(ref as CustomerDetailsRef, id),
        from: customerDetailsProvider,
        name: r'customerDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerDetailsHash,
        dependencies: CustomerDetailsFamily._dependencies,
        allTransitiveDependencies:
            CustomerDetailsFamily._allTransitiveDependencies,
        id: id,
      );

  CustomerDetailsProvider._internal(
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
    FutureOr<Customer?> Function(CustomerDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerDetailsProvider._internal(
        (ref) => create(ref as CustomerDetailsRef),
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
  AutoDisposeFutureProviderElement<Customer?> createElement() {
    return _CustomerDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerDetailsProvider && other.id == id;
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
mixin CustomerDetailsRef on AutoDisposeFutureProviderRef<Customer?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CustomerDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Customer?>
    with CustomerDetailsRef {
  _CustomerDetailsProviderElement(super.provider);

  @override
  String get id => (origin as CustomerDetailsProvider).id;
}

String _$customerFinancialSummaryHash() =>
    r'dfb184122a64f5372433587a2a103e0e6d75ea43';

/// See also [customerFinancialSummary].
@ProviderFor(customerFinancialSummary)
const customerFinancialSummaryProvider = CustomerFinancialSummaryFamily();

/// See also [customerFinancialSummary].
class CustomerFinancialSummaryFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [customerFinancialSummary].
  const CustomerFinancialSummaryFamily();

  /// See also [customerFinancialSummary].
  CustomerFinancialSummaryProvider call(String id) {
    return CustomerFinancialSummaryProvider(id);
  }

  @override
  CustomerFinancialSummaryProvider getProviderOverride(
    covariant CustomerFinancialSummaryProvider provider,
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
  String? get name => r'customerFinancialSummaryProvider';
}

/// See also [customerFinancialSummary].
class CustomerFinancialSummaryProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [customerFinancialSummary].
  CustomerFinancialSummaryProvider(String id)
    : this._internal(
        (ref) =>
            customerFinancialSummary(ref as CustomerFinancialSummaryRef, id),
        from: customerFinancialSummaryProvider,
        name: r'customerFinancialSummaryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerFinancialSummaryHash,
        dependencies: CustomerFinancialSummaryFamily._dependencies,
        allTransitiveDependencies:
            CustomerFinancialSummaryFamily._allTransitiveDependencies,
        id: id,
      );

  CustomerFinancialSummaryProvider._internal(
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
    FutureOr<Map<String, dynamic>> Function(
      CustomerFinancialSummaryRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerFinancialSummaryProvider._internal(
        (ref) => create(ref as CustomerFinancialSummaryRef),
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
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _CustomerFinancialSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerFinancialSummaryProvider && other.id == id;
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
mixin CustomerFinancialSummaryRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CustomerFinancialSummaryProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with CustomerFinancialSummaryRef {
  _CustomerFinancialSummaryProviderElement(super.provider);

  @override
  String get id => (origin as CustomerFinancialSummaryProvider).id;
}

String _$customerTimelineHash() => r'526394854093a803e5c4acde159814bb392d7b7c';

/// See also [customerTimeline].
@ProviderFor(customerTimeline)
const customerTimelineProvider = CustomerTimelineFamily();

/// See also [customerTimeline].
class CustomerTimelineFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [customerTimeline].
  const CustomerTimelineFamily();

  /// See also [customerTimeline].
  CustomerTimelineProvider call(String id) {
    return CustomerTimelineProvider(id);
  }

  @override
  CustomerTimelineProvider getProviderOverride(
    covariant CustomerTimelineProvider provider,
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
  String? get name => r'customerTimelineProvider';
}

/// See also [customerTimeline].
class CustomerTimelineProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [customerTimeline].
  CustomerTimelineProvider(String id)
    : this._internal(
        (ref) => customerTimeline(ref as CustomerTimelineRef, id),
        from: customerTimelineProvider,
        name: r'customerTimelineProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerTimelineHash,
        dependencies: CustomerTimelineFamily._dependencies,
        allTransitiveDependencies:
            CustomerTimelineFamily._allTransitiveDependencies,
        id: id,
      );

  CustomerTimelineProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(CustomerTimelineRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerTimelineProvider._internal(
        (ref) => create(ref as CustomerTimelineRef),
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
    return _CustomerTimelineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerTimelineProvider && other.id == id;
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
mixin CustomerTimelineRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CustomerTimelineProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with CustomerTimelineRef {
  _CustomerTimelineProviderElement(super.provider);

  @override
  String get id => (origin as CustomerTimelineProvider).id;
}

String _$customerContractsHash() => r'3a4901c1186150ae9fc7369978931580ff7005f0';

/// See also [customerContracts].
@ProviderFor(customerContracts)
const customerContractsProvider = CustomerContractsFamily();

/// See also [customerContracts].
class CustomerContractsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [customerContracts].
  const CustomerContractsFamily();

  /// See also [customerContracts].
  CustomerContractsProvider call(String id) {
    return CustomerContractsProvider(id);
  }

  @override
  CustomerContractsProvider getProviderOverride(
    covariant CustomerContractsProvider provider,
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
  String? get name => r'customerContractsProvider';
}

/// See also [customerContracts].
class CustomerContractsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [customerContracts].
  CustomerContractsProvider(String id)
    : this._internal(
        (ref) => customerContracts(ref as CustomerContractsRef, id),
        from: customerContractsProvider,
        name: r'customerContractsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerContractsHash,
        dependencies: CustomerContractsFamily._dependencies,
        allTransitiveDependencies:
            CustomerContractsFamily._allTransitiveDependencies,
        id: id,
      );

  CustomerContractsProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(CustomerContractsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerContractsProvider._internal(
        (ref) => create(ref as CustomerContractsRef),
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
    return _CustomerContractsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerContractsProvider && other.id == id;
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
mixin CustomerContractsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CustomerContractsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with CustomerContractsRef {
  _CustomerContractsProviderElement(super.provider);

  @override
  String get id => (origin as CustomerContractsProvider).id;
}

String _$customerPaymentsHash() => r'3e398b27d41e656205d3fac2e063cab5aa810c31';

/// See also [customerPayments].
@ProviderFor(customerPayments)
const customerPaymentsProvider = CustomerPaymentsFamily();

/// See also [customerPayments].
class CustomerPaymentsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [customerPayments].
  const CustomerPaymentsFamily();

  /// See also [customerPayments].
  CustomerPaymentsProvider call(String id) {
    return CustomerPaymentsProvider(id);
  }

  @override
  CustomerPaymentsProvider getProviderOverride(
    covariant CustomerPaymentsProvider provider,
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
  String? get name => r'customerPaymentsProvider';
}

/// See also [customerPayments].
class CustomerPaymentsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [customerPayments].
  CustomerPaymentsProvider(String id)
    : this._internal(
        (ref) => customerPayments(ref as CustomerPaymentsRef, id),
        from: customerPaymentsProvider,
        name: r'customerPaymentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerPaymentsHash,
        dependencies: CustomerPaymentsFamily._dependencies,
        allTransitiveDependencies:
            CustomerPaymentsFamily._allTransitiveDependencies,
        id: id,
      );

  CustomerPaymentsProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(CustomerPaymentsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerPaymentsProvider._internal(
        (ref) => create(ref as CustomerPaymentsRef),
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
    return _CustomerPaymentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerPaymentsProvider && other.id == id;
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
mixin CustomerPaymentsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CustomerPaymentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with CustomerPaymentsRef {
  _CustomerPaymentsProviderElement(super.provider);

  @override
  String get id => (origin as CustomerPaymentsProvider).id;
}

String _$customerInstallmentsHash() =>
    r'46ce3e15b90bf077028d50dc74f66588d513d5ac';

/// See also [customerInstallments].
@ProviderFor(customerInstallments)
const customerInstallmentsProvider = CustomerInstallmentsFamily();

/// See also [customerInstallments].
class CustomerInstallmentsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [customerInstallments].
  const CustomerInstallmentsFamily();

  /// See also [customerInstallments].
  CustomerInstallmentsProvider call(String id) {
    return CustomerInstallmentsProvider(id);
  }

  @override
  CustomerInstallmentsProvider getProviderOverride(
    covariant CustomerInstallmentsProvider provider,
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
  String? get name => r'customerInstallmentsProvider';
}

/// See also [customerInstallments].
class CustomerInstallmentsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [customerInstallments].
  CustomerInstallmentsProvider(String id)
    : this._internal(
        (ref) => customerInstallments(ref as CustomerInstallmentsRef, id),
        from: customerInstallmentsProvider,
        name: r'customerInstallmentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerInstallmentsHash,
        dependencies: CustomerInstallmentsFamily._dependencies,
        allTransitiveDependencies:
            CustomerInstallmentsFamily._allTransitiveDependencies,
        id: id,
      );

  CustomerInstallmentsProvider._internal(
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
      CustomerInstallmentsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerInstallmentsProvider._internal(
        (ref) => create(ref as CustomerInstallmentsRef),
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
    return _CustomerInstallmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerInstallmentsProvider && other.id == id;
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
mixin CustomerInstallmentsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CustomerInstallmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with CustomerInstallmentsRef {
  _CustomerInstallmentsProviderElement(super.provider);

  @override
  String get id => (origin as CustomerInstallmentsProvider).id;
}

String _$customerDocumentsHash() => r'f55744d7c8e2d0e01b81302e13f78d638ce080e6';

/// See also [customerDocuments].
@ProviderFor(customerDocuments)
const customerDocumentsProvider = CustomerDocumentsFamily();

/// See also [customerDocuments].
class CustomerDocumentsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [customerDocuments].
  const CustomerDocumentsFamily();

  /// See also [customerDocuments].
  CustomerDocumentsProvider call(String id) {
    return CustomerDocumentsProvider(id);
  }

  @override
  CustomerDocumentsProvider getProviderOverride(
    covariant CustomerDocumentsProvider provider,
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
  String? get name => r'customerDocumentsProvider';
}

/// See also [customerDocuments].
class CustomerDocumentsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [customerDocuments].
  CustomerDocumentsProvider(String id)
    : this._internal(
        (ref) => customerDocuments(ref as CustomerDocumentsRef, id),
        from: customerDocumentsProvider,
        name: r'customerDocumentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerDocumentsHash,
        dependencies: CustomerDocumentsFamily._dependencies,
        allTransitiveDependencies:
            CustomerDocumentsFamily._allTransitiveDependencies,
        id: id,
      );

  CustomerDocumentsProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(CustomerDocumentsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerDocumentsProvider._internal(
        (ref) => create(ref as CustomerDocumentsRef),
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
    return _CustomerDocumentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerDocumentsProvider && other.id == id;
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
mixin CustomerDocumentsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CustomerDocumentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with CustomerDocumentsRef {
  _CustomerDocumentsProviderElement(super.provider);

  @override
  String get id => (origin as CustomerDocumentsProvider).id;
}

String _$crmControllerHash() => r'694ac18a64c172e4205dcd9e1a194e3f51601c3b';

/// See also [CrmController].
@ProviderFor(CrmController)
final crmControllerProvider =
    AutoDisposeAsyncNotifierProvider<CrmController, void>.internal(
      CrmController.new,
      name: r'crmControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$crmControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CrmController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
