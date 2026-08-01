// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isMaintenanceModeHash() => r'1f60713c7cd1fcc7b534261f8da31bedf4145e40';

/// See also [isMaintenanceMode].
@ProviderFor(isMaintenanceMode)
final isMaintenanceModeProvider = AutoDisposeFutureProvider<bool>.internal(
  isMaintenanceMode,
  name: r'isMaintenanceModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isMaintenanceModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsMaintenanceModeRef = AutoDisposeFutureProviderRef<bool>;
String _$companySettingsHash() => r'3dc3c944d14393fae1c8b8ff221f6852caa0177a';

/// Provider مخصص لجلب إعدادات المنشأة فقط لاستخدامها في التقارير والـ UI
///
/// Copied from [companySettings].
@ProviderFor(companySettings)
final companySettingsProvider =
    AutoDisposeFutureProvider<CompanySettings>.internal(
      companySettings,
      name: r'companySettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$companySettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompanySettingsRef = AutoDisposeFutureProviderRef<CompanySettings>;
String _$settingsControllerHash() =>
    r'b24a812fb8ce47b5d3f2c3e534616fe686edab2f';

/// See also [SettingsController].
@ProviderFor(SettingsController)
final settingsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      SettingsController,
      List<SystemSetting>
    >.internal(
      SettingsController.new,
      name: r'settingsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettingsController = AutoDisposeAsyncNotifier<List<SystemSetting>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
