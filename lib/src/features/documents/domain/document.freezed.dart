// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppDocument _$AppDocumentFromJson(Map<String, dynamic> json) {
  return _AppDocument.fromJson(json);
}

/// @nodoc
mixin _$AppDocument {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'contract_id')
  String? get contractId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String? get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'investor_id')
  String? get investorId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_path')
  String get filePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'document_url')
  String get documentUrl => throw _privateConstructorUsedError;
  @DocumentTypeConverter()
  @JsonKey(name: 'document_type')
  DocumentType get type => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AppDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppDocumentCopyWith<AppDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppDocumentCopyWith<$Res> {
  factory $AppDocumentCopyWith(
    AppDocument value,
    $Res Function(AppDocument) then,
  ) = _$AppDocumentCopyWithImpl<$Res, AppDocument>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'contract_id') String? contractId,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'investor_id') String? investorId,
    String name,
    @JsonKey(name: 'file_path') String filePath,
    @JsonKey(name: 'document_url') String documentUrl,
    @DocumentTypeConverter() @JsonKey(name: 'document_type') DocumentType type,
    int version,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$AppDocumentCopyWithImpl<$Res, $Val extends AppDocument>
    implements $AppDocumentCopyWith<$Res> {
  _$AppDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contractId = freezed,
    Object? customerId = freezed,
    Object? investorId = freezed,
    Object? name = null,
    Object? filePath = null,
    Object? documentUrl = null,
    Object? type = null,
    Object? version = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            contractId: freezed == contractId
                ? _value.contractId
                : contractId // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerId: freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            investorId: freezed == investorId
                ? _value.investorId
                : investorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            filePath: null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String,
            documentUrl: null == documentUrl
                ? _value.documentUrl
                : documentUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as DocumentType,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppDocumentImplCopyWith<$Res>
    implements $AppDocumentCopyWith<$Res> {
  factory _$$AppDocumentImplCopyWith(
    _$AppDocumentImpl value,
    $Res Function(_$AppDocumentImpl) then,
  ) = __$$AppDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'contract_id') String? contractId,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'investor_id') String? investorId,
    String name,
    @JsonKey(name: 'file_path') String filePath,
    @JsonKey(name: 'document_url') String documentUrl,
    @DocumentTypeConverter() @JsonKey(name: 'document_type') DocumentType type,
    int version,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$AppDocumentImplCopyWithImpl<$Res>
    extends _$AppDocumentCopyWithImpl<$Res, _$AppDocumentImpl>
    implements _$$AppDocumentImplCopyWith<$Res> {
  __$$AppDocumentImplCopyWithImpl(
    _$AppDocumentImpl _value,
    $Res Function(_$AppDocumentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contractId = freezed,
    Object? customerId = freezed,
    Object? investorId = freezed,
    Object? name = null,
    Object? filePath = null,
    Object? documentUrl = null,
    Object? type = null,
    Object? version = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AppDocumentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        contractId: freezed == contractId
            ? _value.contractId
            : contractId // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        investorId: freezed == investorId
            ? _value.investorId
            : investorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        documentUrl: null == documentUrl
            ? _value.documentUrl
            : documentUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as DocumentType,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppDocumentImpl implements _AppDocument {
  const _$AppDocumentImpl({
    required this.id,
    @JsonKey(name: 'contract_id') this.contractId,
    @JsonKey(name: 'customer_id') this.customerId,
    @JsonKey(name: 'investor_id') this.investorId,
    required this.name,
    @JsonKey(name: 'file_path') required this.filePath,
    @JsonKey(name: 'document_url') required this.documentUrl,
    @DocumentTypeConverter() @JsonKey(name: 'document_type') required this.type,
    this.version = 1,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$AppDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppDocumentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'contract_id')
  final String? contractId;
  @override
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @override
  @JsonKey(name: 'investor_id')
  final String? investorId;
  @override
  final String name;
  @override
  @JsonKey(name: 'file_path')
  final String filePath;
  @override
  @JsonKey(name: 'document_url')
  final String documentUrl;
  @override
  @DocumentTypeConverter()
  @JsonKey(name: 'document_type')
  final DocumentType type;
  @override
  @JsonKey()
  final int version;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'AppDocument(id: $id, contractId: $contractId, customerId: $customerId, investorId: $investorId, name: $name, filePath: $filePath, documentUrl: $documentUrl, type: $type, version: $version, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppDocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.contractId, contractId) ||
                other.contractId == contractId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.investorId, investorId) ||
                other.investorId == investorId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.documentUrl, documentUrl) ||
                other.documentUrl == documentUrl) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    contractId,
    customerId,
    investorId,
    name,
    filePath,
    documentUrl,
    type,
    version,
    createdAt,
  );

  /// Create a copy of AppDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppDocumentImplCopyWith<_$AppDocumentImpl> get copyWith =>
      __$$AppDocumentImplCopyWithImpl<_$AppDocumentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppDocumentImplToJson(this);
  }
}

abstract class _AppDocument implements AppDocument {
  const factory _AppDocument({
    required final String id,
    @JsonKey(name: 'contract_id') final String? contractId,
    @JsonKey(name: 'customer_id') final String? customerId,
    @JsonKey(name: 'investor_id') final String? investorId,
    required final String name,
    @JsonKey(name: 'file_path') required final String filePath,
    @JsonKey(name: 'document_url') required final String documentUrl,
    @DocumentTypeConverter()
    @JsonKey(name: 'document_type')
    required final DocumentType type,
    final int version,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$AppDocumentImpl;

  factory _AppDocument.fromJson(Map<String, dynamic> json) =
      _$AppDocumentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'contract_id')
  String? get contractId;
  @override
  @JsonKey(name: 'customer_id')
  String? get customerId;
  @override
  @JsonKey(name: 'investor_id')
  String? get investorId;
  @override
  String get name;
  @override
  @JsonKey(name: 'file_path')
  String get filePath;
  @override
  @JsonKey(name: 'document_url')
  String get documentUrl;
  @override
  @DocumentTypeConverter()
  @JsonKey(name: 'document_type')
  DocumentType get type;
  @override
  int get version;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of AppDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppDocumentImplCopyWith<_$AppDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
