// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'24440cba715f9677d48d7649af3ca4cdd1531476';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<AppUser?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<AppUser?>;
String _$currentUserHash() => r'2cbb899b5ce8f7a26eb391e91b841465b79f84f3';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<AppUser?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<AppUser?>;
String _$refreshedCurrentUserHash() =>
    r'412aaf3b4c95275c231befe75f7accfc2e542883';

/// Provider منفصل يُستخدم في pending_approval_screen لإعادة تحميل البروفايل يدوياً
///
/// Copied from [refreshedCurrentUser].
@ProviderFor(refreshedCurrentUser)
final refreshedCurrentUserProvider =
    AutoDisposeFutureProvider<AppUser?>.internal(
      refreshedCurrentUser,
      name: r'refreshedCurrentUserProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$refreshedCurrentUserHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RefreshedCurrentUserRef = AutoDisposeFutureProviderRef<AppUser?>;
String _$authControllerHash() => r'6049b4ee565e1c28b56560740dd5dc4df5bd6566';

/// See also [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>.internal(
      AuthController.new,
      name: r'authControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
