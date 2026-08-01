// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inventoryStatsHash() => r'589fc8048b91b94c61fc2e0bd49139581a6c263b';

/// See also [inventoryStats].
@ProviderFor(inventoryStats)
final inventoryStatsProvider = FutureProvider<Map<String, dynamic>>.internal(
  inventoryStats,
  name: r'inventoryStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InventoryStatsRef = FutureProviderRef<Map<String, dynamic>>;
String _$vehicleMaintenanceLogsHash() =>
    r'534724cafb7e22fbfc682a46ba8f405276cf86cc';

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

/// See also [vehicleMaintenanceLogs].
@ProviderFor(vehicleMaintenanceLogs)
const vehicleMaintenanceLogsProvider = VehicleMaintenanceLogsFamily();

/// See also [vehicleMaintenanceLogs].
class VehicleMaintenanceLogsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [vehicleMaintenanceLogs].
  const VehicleMaintenanceLogsFamily();

  /// See also [vehicleMaintenanceLogs].
  VehicleMaintenanceLogsProvider call(String vehicleId) {
    return VehicleMaintenanceLogsProvider(vehicleId);
  }

  @override
  VehicleMaintenanceLogsProvider getProviderOverride(
    covariant VehicleMaintenanceLogsProvider provider,
  ) {
    return call(provider.vehicleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vehicleMaintenanceLogsProvider';
}

/// See also [vehicleMaintenanceLogs].
class VehicleMaintenanceLogsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [vehicleMaintenanceLogs].
  VehicleMaintenanceLogsProvider(String vehicleId)
    : this._internal(
        (ref) =>
            vehicleMaintenanceLogs(ref as VehicleMaintenanceLogsRef, vehicleId),
        from: vehicleMaintenanceLogsProvider,
        name: r'vehicleMaintenanceLogsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$vehicleMaintenanceLogsHash,
        dependencies: VehicleMaintenanceLogsFamily._dependencies,
        allTransitiveDependencies:
            VehicleMaintenanceLogsFamily._allTransitiveDependencies,
        vehicleId: vehicleId,
      );

  VehicleMaintenanceLogsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleId,
  }) : super.internal();

  final String vehicleId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
      VehicleMaintenanceLogsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VehicleMaintenanceLogsProvider._internal(
        (ref) => create(ref as VehicleMaintenanceLogsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleId: vehicleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _VehicleMaintenanceLogsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleMaintenanceLogsProvider &&
        other.vehicleId == vehicleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VehicleMaintenanceLogsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `vehicleId` of this provider.
  String get vehicleId;
}

class _VehicleMaintenanceLogsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with VehicleMaintenanceLogsRef {
  _VehicleMaintenanceLogsProviderElement(super.provider);

  @override
  String get vehicleId => (origin as VehicleMaintenanceLogsProvider).vehicleId;
}

String _$vehiclesListHash() => r'3576c92246e28739d5a19dce69d07a219fff2b93';

/// See also [vehiclesList].
@ProviderFor(vehiclesList)
const vehiclesListProvider = VehiclesListFamily();

/// See also [vehiclesList].
class VehiclesListFamily extends Family<AsyncValue<List<Vehicle>>> {
  /// See also [vehiclesList].
  const VehiclesListFamily();

  /// See also [vehiclesList].
  VehiclesListProvider call({
    String? searchQuery,
    String? status,
    String? make,
  }) {
    return VehiclesListProvider(
      searchQuery: searchQuery,
      status: status,
      make: make,
    );
  }

  @override
  VehiclesListProvider getProviderOverride(
    covariant VehiclesListProvider provider,
  ) {
    return call(
      searchQuery: provider.searchQuery,
      status: provider.status,
      make: provider.make,
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
  String? get name => r'vehiclesListProvider';
}

/// See also [vehiclesList].
class VehiclesListProvider extends FutureProvider<List<Vehicle>> {
  /// See also [vehiclesList].
  VehiclesListProvider({String? searchQuery, String? status, String? make})
    : this._internal(
        (ref) => vehiclesList(
          ref as VehiclesListRef,
          searchQuery: searchQuery,
          status: status,
          make: make,
        ),
        from: vehiclesListProvider,
        name: r'vehiclesListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$vehiclesListHash,
        dependencies: VehiclesListFamily._dependencies,
        allTransitiveDependencies:
            VehiclesListFamily._allTransitiveDependencies,
        searchQuery: searchQuery,
        status: status,
        make: make,
      );

  VehiclesListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
    required this.status,
    required this.make,
  }) : super.internal();

  final String? searchQuery;
  final String? status;
  final String? make;

  @override
  Override overrideWith(
    FutureOr<List<Vehicle>> Function(VehiclesListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VehiclesListProvider._internal(
        (ref) => create(ref as VehiclesListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
        status: status,
        make: make,
      ),
    );
  }

  @override
  FutureProviderElement<List<Vehicle>> createElement() {
    return _VehiclesListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VehiclesListProvider &&
        other.searchQuery == searchQuery &&
        other.status == status &&
        other.make == make;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, make.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VehiclesListRef on FutureProviderRef<List<Vehicle>> {
  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;

  /// The parameter `status` of this provider.
  String? get status;

  /// The parameter `make` of this provider.
  String? get make;
}

class _VehiclesListProviderElement extends FutureProviderElement<List<Vehicle>>
    with VehiclesListRef {
  _VehiclesListProviderElement(super.provider);

  @override
  String? get searchQuery => (origin as VehiclesListProvider).searchQuery;
  @override
  String? get status => (origin as VehiclesListProvider).status;
  @override
  String? get make => (origin as VehiclesListProvider).make;
}

String _$vehicleDetailsHash() => r'eb63ceab71f8fe19f7671c6e815b89cb469e6c91';

/// See also [vehicleDetails].
@ProviderFor(vehicleDetails)
const vehicleDetailsProvider = VehicleDetailsFamily();

/// See also [vehicleDetails].
class VehicleDetailsFamily extends Family<AsyncValue<Vehicle?>> {
  /// See also [vehicleDetails].
  const VehicleDetailsFamily();

  /// See also [vehicleDetails].
  VehicleDetailsProvider call(String id) {
    return VehicleDetailsProvider(id);
  }

  @override
  VehicleDetailsProvider getProviderOverride(
    covariant VehicleDetailsProvider provider,
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
  String? get name => r'vehicleDetailsProvider';
}

/// See also [vehicleDetails].
class VehicleDetailsProvider extends AutoDisposeFutureProvider<Vehicle?> {
  /// See also [vehicleDetails].
  VehicleDetailsProvider(String id)
    : this._internal(
        (ref) => vehicleDetails(ref as VehicleDetailsRef, id),
        from: vehicleDetailsProvider,
        name: r'vehicleDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$vehicleDetailsHash,
        dependencies: VehicleDetailsFamily._dependencies,
        allTransitiveDependencies:
            VehicleDetailsFamily._allTransitiveDependencies,
        id: id,
      );

  VehicleDetailsProvider._internal(
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
    FutureOr<Vehicle?> Function(VehicleDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VehicleDetailsProvider._internal(
        (ref) => create(ref as VehicleDetailsRef),
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
  AutoDisposeFutureProviderElement<Vehicle?> createElement() {
    return _VehicleDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleDetailsProvider && other.id == id;
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
mixin VehicleDetailsRef on AutoDisposeFutureProviderRef<Vehicle?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _VehicleDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Vehicle?>
    with VehicleDetailsRef {
  _VehicleDetailsProviderElement(super.provider);

  @override
  String get id => (origin as VehicleDetailsProvider).id;
}

String _$inventoryControllerHash() =>
    r'9ebfbd91a0238a283be99405a53bc724d6dfa76b';

/// See also [InventoryController].
@ProviderFor(InventoryController)
final inventoryControllerProvider =
    AutoDisposeAsyncNotifierProvider<InventoryController, void>.internal(
      InventoryController.new,
      name: r'inventoryControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inventoryControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InventoryController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
