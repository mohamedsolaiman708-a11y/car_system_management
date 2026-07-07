import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    required String id,
    required String vin,
    required String make,
    required String model,
    required int year,
    String? color,
    @JsonKey(name: 'license_plate') String? licensePlate,
    required String status, // available, on_contract, maintenance
    @JsonKey(name: 'purchase_price') required double purchasePrice,
    @JsonKey(name: 'estimated_market_value') double? estimatedMarketValue,
    @JsonKey(name: 'technical_specs') @Default({}) Map<String, dynamic> technicalSpecs,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
}
