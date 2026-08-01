// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jobsStatsHash() => r'8538fafed53c3c52734e7a33927ebb3c5a8ab38a';

/// See also [jobsStats].
@ProviderFor(jobsStats)
final jobsStatsProvider = AutoDisposeFutureProvider<Map<String, int>>.internal(
  jobsStats,
  name: r'jobsStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jobsStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JobsStatsRef = AutoDisposeFutureProviderRef<Map<String, int>>;
String _$jobFilterHash() => r'de57caf923fb6d68ea532412480c93f10a247b91';

/// See also [JobFilter].
@ProviderFor(JobFilter)
final jobFilterProvider =
    AutoDisposeNotifierProvider<JobFilter, JobStatus?>.internal(
      JobFilter.new,
      name: r'jobFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$jobFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$JobFilter = AutoDisposeNotifier<JobStatus?>;
String _$jobsListControllerHash() =>
    r'8eecc7645fea672bd8fbadf9d644455812be84f6';

/// See also [JobsListController].
@ProviderFor(JobsListController)
final jobsListControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      JobsListController,
      List<BackgroundJob>
    >.internal(
      JobsListController.new,
      name: r'jobsListControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$jobsListControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$JobsListController = AutoDisposeAsyncNotifier<List<BackgroundJob>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
