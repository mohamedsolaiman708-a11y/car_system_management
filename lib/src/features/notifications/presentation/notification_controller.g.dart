// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadNotificationsCountHash() =>
    r'd723addc4e04c4c982a916fe180b21ac7956e122';

/// See also [unreadNotificationsCount].
@ProviderFor(unreadNotificationsCount)
final unreadNotificationsCountProvider = AutoDisposeProvider<int>.internal(
  unreadNotificationsCount,
  name: r'unreadNotificationsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadNotificationsCountRef = AutoDisposeProviderRef<int>;
String _$notificationControllerHash() =>
    r'373991364ec51274a4900da74ae709571a60c7bf';

/// See also [NotificationController].
@ProviderFor(NotificationController)
final notificationControllerProvider =
    AutoDisposeStreamNotifierProvider<
      NotificationController,
      List<AppNotification>
    >.internal(
      NotificationController.new,
      name: r'notificationControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationController =
    AutoDisposeStreamNotifier<List<AppNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
