// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disaster_recovery_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fiscalPeriodsHash() => r'f05f113b06bc713a417a440b1edc6894a4b4149b';

/// See also [fiscalPeriods].
@ProviderFor(fiscalPeriods)
final fiscalPeriodsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      fiscalPeriods,
      name: r'fiscalPeriodsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fiscalPeriodsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FiscalPeriodsRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$systemFreezeStatusHash() =>
    r'1c1c722ed3622d2326a5fdb6299ac5931d7a2663';

/// See also [systemFreezeStatus].
@ProviderFor(systemFreezeStatus)
final systemFreezeStatusProvider = AutoDisposeFutureProvider<bool>.internal(
  systemFreezeStatus,
  name: r'systemFreezeStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$systemFreezeStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SystemFreezeStatusRef = AutoDisposeFutureProviderRef<bool>;
String _$disasterRecoveryControllerHash() =>
    r'9e4705f457158354040b41c115d9f1338b06c307';

/// See also [DisasterRecoveryController].
@ProviderFor(DisasterRecoveryController)
final disasterRecoveryControllerProvider =
    AutoDisposeAsyncNotifierProvider<DisasterRecoveryController, void>.internal(
      DisasterRecoveryController.new,
      name: r'disasterRecoveryControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$disasterRecoveryControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DisasterRecoveryController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
