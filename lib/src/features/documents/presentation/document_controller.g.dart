// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentsListHash() => r'98daf8b429a06e0cc170e48033bc1e797d09851d';

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

/// See also [documentsList].
@ProviderFor(documentsList)
const documentsListProvider = DocumentsListFamily();

/// See also [documentsList].
class DocumentsListFamily extends Family<AsyncValue<List<AppDocument>>> {
  /// See also [documentsList].
  const DocumentsListFamily();

  /// See also [documentsList].
  DocumentsListProvider call({
    String? customerId,
    String? contractId,
    String? investorId,
  }) {
    return DocumentsListProvider(
      customerId: customerId,
      contractId: contractId,
      investorId: investorId,
    );
  }

  @override
  DocumentsListProvider getProviderOverride(
    covariant DocumentsListProvider provider,
  ) {
    return call(
      customerId: provider.customerId,
      contractId: provider.contractId,
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
  String? get name => r'documentsListProvider';
}

/// See also [documentsList].
class DocumentsListProvider extends FutureProvider<List<AppDocument>> {
  /// See also [documentsList].
  DocumentsListProvider({
    String? customerId,
    String? contractId,
    String? investorId,
  }) : this._internal(
         (ref) => documentsList(
           ref as DocumentsListRef,
           customerId: customerId,
           contractId: contractId,
           investorId: investorId,
         ),
         from: documentsListProvider,
         name: r'documentsListProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$documentsListHash,
         dependencies: DocumentsListFamily._dependencies,
         allTransitiveDependencies:
             DocumentsListFamily._allTransitiveDependencies,
         customerId: customerId,
         contractId: contractId,
         investorId: investorId,
       );

  DocumentsListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.customerId,
    required this.contractId,
    required this.investorId,
  }) : super.internal();

  final String? customerId;
  final String? contractId;
  final String? investorId;

  @override
  Override overrideWith(
    FutureOr<List<AppDocument>> Function(DocumentsListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentsListProvider._internal(
        (ref) => create(ref as DocumentsListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        customerId: customerId,
        contractId: contractId,
        investorId: investorId,
      ),
    );
  }

  @override
  FutureProviderElement<List<AppDocument>> createElement() {
    return _DocumentsListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentsListProvider &&
        other.customerId == customerId &&
        other.contractId == contractId &&
        other.investorId == investorId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);
    hash = _SystemHash.combine(hash, contractId.hashCode);
    hash = _SystemHash.combine(hash, investorId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentsListRef on FutureProviderRef<List<AppDocument>> {
  /// The parameter `customerId` of this provider.
  String? get customerId;

  /// The parameter `contractId` of this provider.
  String? get contractId;

  /// The parameter `investorId` of this provider.
  String? get investorId;
}

class _DocumentsListProviderElement
    extends FutureProviderElement<List<AppDocument>>
    with DocumentsListRef {
  _DocumentsListProviderElement(super.provider);

  @override
  String? get customerId => (origin as DocumentsListProvider).customerId;
  @override
  String? get contractId => (origin as DocumentsListProvider).contractId;
  @override
  String? get investorId => (origin as DocumentsListProvider).investorId;
}

String _$documentControllerHash() =>
    r'b184f0c0682ed66518f6851ee3b719c86db73fb2';

/// See also [DocumentController].
@ProviderFor(DocumentController)
final documentControllerProvider =
    AutoDisposeAsyncNotifierProvider<DocumentController, void>.internal(
      DocumentController.new,
      name: r'documentControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$documentControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DocumentController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
