// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleImpl _$$VehicleImplFromJson(
  Map<String, dynamic> json,
) => _$VehicleImpl(
  id: json['id'] as String,
  vin: json['vin'] as String,
  make: json['make'] as String,
  model: json['model'] as String,
  year: (json['year'] as num).toInt(),
  color: json['color'] as String?,
  licensePlate: json['license_plate'] as String?,
  status: json['status'] as String,
  purchasePrice: (json['purchase_price'] as num).toDouble(),
  estimatedMarketValue: (json['estimated_market_value'] as num?)?.toDouble(),
  technicalSpecs: json['technical_specs'] as Map<String, dynamic>? ?? const {},
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$VehicleImplToJson(_$VehicleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vin': instance.vin,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'color': instance.color,
      'license_plate': instance.licensePlate,
      'status': instance.status,
      'purchase_price': instance.purchasePrice,
      'estimated_market_value': instance.estimatedMarketValue,
      'technical_specs': instance.technicalSpecs,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
