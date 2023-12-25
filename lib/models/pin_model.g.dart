// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PinImpl _$$PinImplFromJson(Map<String, dynamic> json) => _$PinImpl(
      type: $enumDecode(_$PinTypeEnumMap, json['type']),
      position: const PositionConverter()
          .fromJson(json['position'] as Map<String, dynamic>),
      description: json['description'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$$PinImplToJson(_$PinImpl instance) => <String, dynamic>{
      'type': _$PinTypeEnumMap[instance.type]!,
      'position': const PositionConverter().toJson(instance.position),
      'description': instance.description,
      'image': instance.image,
    };

const _$PinTypeEnumMap = {
  PinType.green: 'green',
  PinType.blue: 'blue',
  PinType.red: 'red',
};
