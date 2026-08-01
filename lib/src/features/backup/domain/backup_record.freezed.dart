// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BackupRecord _$BackupRecordFromJson(Map<String, dynamic> json) {
  return _BackupRecord.fromJson(json);
}

/// @nodoc
mixin _$BackupRecord {
  String get id => throw _privateConstructorUsedError;
  String get filename => throw _privateConstructorUsedError;
  @JsonKey(name: 'size_bytes')
  int? get sizeBytes => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'backup_type')
  String get backupType => throw _privateConstructorUsedError;
  @JsonKey(name: 'download_url')
  String? get downloadUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String? get createdBy => throw _privateConstructorUsedError;

  /// Serializes this BackupRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupRecordCopyWith<BackupRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupRecordCopyWith<$Res> {
  factory $BackupRecordCopyWith(
    BackupRecord value,
    $Res Function(BackupRecord) then,
  ) = _$BackupRecordCopyWithImpl<$Res, BackupRecord>;
  @useResult
  $Res call({
    String id,
    String filename,
    @JsonKey(name: 'size_bytes') int? sizeBytes,
    String status,
    @JsonKey(name: 'backup_type') String backupType,
    @JsonKey(name: 'download_url') String? downloadUrl,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'created_by') String? createdBy,
  });
}

/// @nodoc
class _$BackupRecordCopyWithImpl<$Res, $Val extends BackupRecord>
    implements $BackupRecordCopyWith<$Res> {
  _$BackupRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? filename = null,
    Object? sizeBytes = freezed,
    Object? status = null,
    Object? backupType = null,
    Object? downloadUrl = freezed,
    Object? createdAt = null,
    Object? createdBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            filename: null == filename
                ? _value.filename
                : filename // ignore: cast_nullable_to_non_nullable
                      as String,
            sizeBytes: freezed == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            backupType: null == backupType
                ? _value.backupType
                : backupType // ignore: cast_nullable_to_non_nullable
                      as String,
            downloadUrl: freezed == downloadUrl
                ? _value.downloadUrl
                : downloadUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdBy: freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackupRecordImplCopyWith<$Res>
    implements $BackupRecordCopyWith<$Res> {
  factory _$$BackupRecordImplCopyWith(
    _$BackupRecordImpl value,
    $Res Function(_$BackupRecordImpl) then,
  ) = __$$BackupRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String filename,
    @JsonKey(name: 'size_bytes') int? sizeBytes,
    String status,
    @JsonKey(name: 'backup_type') String backupType,
    @JsonKey(name: 'download_url') String? downloadUrl,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'created_by') String? createdBy,
  });
}

/// @nodoc
class __$$BackupRecordImplCopyWithImpl<$Res>
    extends _$BackupRecordCopyWithImpl<$Res, _$BackupRecordImpl>
    implements _$$BackupRecordImplCopyWith<$Res> {
  __$$BackupRecordImplCopyWithImpl(
    _$BackupRecordImpl _value,
    $Res Function(_$BackupRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? filename = null,
    Object? sizeBytes = freezed,
    Object? status = null,
    Object? backupType = null,
    Object? downloadUrl = freezed,
    Object? createdAt = null,
    Object? createdBy = freezed,
  }) {
    return _then(
      _$BackupRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        filename: null == filename
            ? _value.filename
            : filename // ignore: cast_nullable_to_non_nullable
                  as String,
        sizeBytes: freezed == sizeBytes
            ? _value.sizeBytes
            : sizeBytes // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        backupType: null == backupType
            ? _value.backupType
            : backupType // ignore: cast_nullable_to_non_nullable
                  as String,
        downloadUrl: freezed == downloadUrl
            ? _value.downloadUrl
            : downloadUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdBy: freezed == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BackupRecordImpl implements _BackupRecord {
  const _$BackupRecordImpl({
    required this.id,
    required this.filename,
    @JsonKey(name: 'size_bytes') this.sizeBytes,
    this.status = 'completed',
    @JsonKey(name: 'backup_type') this.backupType = 'automatic',
    @JsonKey(name: 'download_url') this.downloadUrl,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'created_by') this.createdBy,
  });

  factory _$BackupRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String filename;
  @override
  @JsonKey(name: 'size_bytes')
  final int? sizeBytes;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'backup_type')
  final String backupType;
  @override
  @JsonKey(name: 'download_url')
  final String? downloadUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'created_by')
  final String? createdBy;

  @override
  String toString() {
    return 'BackupRecord(id: $id, filename: $filename, sizeBytes: $sizeBytes, status: $status, backupType: $backupType, downloadUrl: $downloadUrl, createdAt: $createdAt, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.backupType, backupType) ||
                other.backupType == backupType) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    filename,
    sizeBytes,
    status,
    backupType,
    downloadUrl,
    createdAt,
    createdBy,
  );

  /// Create a copy of BackupRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupRecordImplCopyWith<_$BackupRecordImpl> get copyWith =>
      __$$BackupRecordImplCopyWithImpl<_$BackupRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupRecordImplToJson(this);
  }
}

abstract class _BackupRecord implements BackupRecord {
  const factory _BackupRecord({
    required final String id,
    required final String filename,
    @JsonKey(name: 'size_bytes') final int? sizeBytes,
    final String status,
    @JsonKey(name: 'backup_type') final String backupType,
    @JsonKey(name: 'download_url') final String? downloadUrl,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'created_by') final String? createdBy,
  }) = _$BackupRecordImpl;

  factory _BackupRecord.fromJson(Map<String, dynamic> json) =
      _$BackupRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get filename;
  @override
  @JsonKey(name: 'size_bytes')
  int? get sizeBytes;
  @override
  String get status;
  @override
  @JsonKey(name: 'backup_type')
  String get backupType;
  @override
  @JsonKey(name: 'download_url')
  String? get downloadUrl;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'created_by')
  String? get createdBy;

  /// Create a copy of BackupRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupRecordImplCopyWith<_$BackupRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
