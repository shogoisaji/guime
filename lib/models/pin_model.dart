import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guime/theme/color_theme.dart';

part 'pin_model.freezed.dart';
part 'pin_model.g.dart';

enum PinType { green, blue, red }

extension PinTypeExtension on PinType {
  Color get color {
    switch (this) {
      case PinType.blue:
        return const Color(MyColors.blue);
      case PinType.green:
        return const Color(MyColors.green);
      case PinType.red:
        return const Color(MyColors.red);
      default:
        return Colors.red;
    }
  }
}

@freezed
class Pin with _$Pin {
  factory Pin({
    required PinType type,
    @PositionConverter() required Position position,
    required String description,
    required String image,
  }) = _Pin;

  factory Pin.fromJson(Map<String, dynamic> json) => _$PinFromJson(json);
}

class PositionConverter implements JsonConverter<Position, Map<String, dynamic>> {
  const PositionConverter();

  @override
  Position fromJson(Map<String, dynamic> json) {
    return Position(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      floor: null,
      isMocked: false,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  @override
  Map<String, dynamic> toJson(Position position) => {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': position.timestamp.toString(),
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'heading': position.heading,
        'speed': position.speed,
        'speedAccuracy': position.speedAccuracy,
        'floor': position.floor,
        'isMocked': position.isMocked,
        'altitudeAccuracy': position.altitudeAccuracy,
        'headingAccuracy': position.headingAccuracy,
      };
}
