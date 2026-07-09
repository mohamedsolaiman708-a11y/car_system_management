import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_setting.freezed.dart';
part 'system_setting.g.dart';

@freezed
class SystemSetting with _$SystemSetting {
  const factory SystemSetting({
    required String id,
    required String key,
    required Map<String, dynamic> value,
    String? description,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _SystemSetting;

  factory SystemSetting.fromJson(Map<String, dynamic> json) => _$SystemSettingFromJson(json);
}
