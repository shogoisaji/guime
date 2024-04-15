// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pin_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Pin _$PinFromJson(Map<String, dynamic> json) {
  return _Pin.fromJson(json);
}

/// @nodoc
mixin _$Pin {
  PinType get type => throw _privateConstructorUsedError;
  @PositionConverter()
  Position get position => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PinCopyWith<Pin> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PinCopyWith<$Res> {
  factory $PinCopyWith(Pin value, $Res Function(Pin) then) =
      _$PinCopyWithImpl<$Res, Pin>;
  @useResult
  $Res call(
      {PinType type,
      @PositionConverter() Position position,
      String description,
      String image});
}

/// @nodoc
class _$PinCopyWithImpl<$Res, $Val extends Pin> implements $PinCopyWith<$Res> {
  _$PinCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? position = null,
    Object? description = null,
    Object? image = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PinType,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Position,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PinImplCopyWith<$Res> implements $PinCopyWith<$Res> {
  factory _$$PinImplCopyWith(_$PinImpl value, $Res Function(_$PinImpl) then) =
      __$$PinImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PinType type,
      @PositionConverter() Position position,
      String description,
      String image});
}

/// @nodoc
class __$$PinImplCopyWithImpl<$Res> extends _$PinCopyWithImpl<$Res, _$PinImpl>
    implements _$$PinImplCopyWith<$Res> {
  __$$PinImplCopyWithImpl(_$PinImpl _value, $Res Function(_$PinImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? position = null,
    Object? description = null,
    Object? image = null,
  }) {
    return _then(_$PinImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PinType,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Position,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PinImpl implements _Pin {
  _$PinImpl(
      {required this.type,
      @PositionConverter() required this.position,
      required this.description,
      required this.image});

  factory _$PinImpl.fromJson(Map<String, dynamic> json) =>
      _$$PinImplFromJson(json);

  @override
  final PinType type;
  @override
  @PositionConverter()
  final Position position;
  @override
  final String description;
  @override
  final String image;

  @override
  String toString() {
    return 'Pin(type: $type, position: $position, description: $description, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PinImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, position, description, image);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PinImplCopyWith<_$PinImpl> get copyWith =>
      __$$PinImplCopyWithImpl<_$PinImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PinImplToJson(
      this,
    );
  }
}

abstract class _Pin implements Pin {
  factory _Pin(
      {required final PinType type,
      @PositionConverter() required final Position position,
      required final String description,
      required final String image}) = _$PinImpl;

  factory _Pin.fromJson(Map<String, dynamic> json) = _$PinImpl.fromJson;

  @override
  PinType get type;
  @override
  @PositionConverter()
  Position get position;
  @override
  String get description;
  @override
  String get image;
  @override
  @JsonKey(ignore: true)
  _$$PinImplCopyWith<_$PinImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
