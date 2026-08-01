// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableRolesHash() => r'28f1fa7386ca0fa4852b18ced6312caccfe937f3';

/// See also [availableRoles].
@ProviderFor(availableRoles)
final availableRolesProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      availableRoles,
      name: r'availableRolesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$availableRolesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableRolesRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$staffListControllerHash() =>
    r'3a03cf9e0a7f3d52791eaf4dd31bb4611d35fab5';

/// See also [StaffListController].
@ProviderFor(StaffListController)
final staffListControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      StaffListController,
      List<AppUser>
    >.internal(
      StaffListController.new,
      name: r'staffListControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$staffListControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StaffListController = AutoDisposeAsyncNotifier<List<AppUser>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
