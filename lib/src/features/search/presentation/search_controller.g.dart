// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredSearchResultsHash() =>
    r'820d9b8d3874120e4dd25e010f3cf9657660deed';

/// See also [filteredSearchResults].
@ProviderFor(filteredSearchResults)
final filteredSearchResultsProvider =
    AutoDisposeProvider<List<SearchResult>>.internal(
      filteredSearchResults,
      name: r'filteredSearchResultsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredSearchResultsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredSearchResultsRef = AutoDisposeProviderRef<List<SearchResult>>;
String _$globalSearchControllerHash() =>
    r'd8e19fb1530ad1564f74a513ea4d49f29539e0cc';

/// See also [GlobalSearchController].
@ProviderFor(GlobalSearchController)
final globalSearchControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      GlobalSearchController,
      List<SearchResult>
    >.internal(
      GlobalSearchController.new,
      name: r'globalSearchControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$globalSearchControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GlobalSearchController = AutoDisposeAsyncNotifier<List<SearchResult>>;
String _$searchQueryControllerHash() =>
    r'8e47a1521dc638066f8beeeffd09d4b01c90428c';

/// See also [SearchQueryController].
@ProviderFor(SearchQueryController)
final searchQueryControllerProvider =
    AutoDisposeNotifierProvider<SearchQueryController, String>.internal(
      SearchQueryController.new,
      name: r'searchQueryControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchQueryControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchQueryController = AutoDisposeNotifier<String>;
String _$searchFilterControllerHash() =>
    r'60bcbf39870a658d9ec788794f7c1612cca7bdf9';

/// See also [SearchFilterController].
@ProviderFor(SearchFilterController)
final searchFilterControllerProvider =
    AutoDisposeNotifierProvider<
      SearchFilterController,
      SearchEntityType?
    >.internal(
      SearchFilterController.new,
      name: r'searchFilterControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchFilterControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchFilterController = AutoDisposeNotifier<SearchEntityType?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
