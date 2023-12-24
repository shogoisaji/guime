import 'package:flutter/material.dart';
import 'package:guime/theme/color_theme.dart';

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

class Pin {
  final PinType type;
  final String position;
  final String description;
  final String image;

  Pin({
    required this.type,
    required this.position,
    required this.description,
    required this.image,
  });

  factory Pin.fromJson(Map<String, dynamic> json) {
    return Pin(
      type: json['type'] == 'red'
          ? PinType.red
          : json['type'] == 'blue'
              ? PinType.blue
              : PinType.green,
      position: json['position'],
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type == PinType.red
          ? 'red'
          : type == PinType.blue
              ? 'blue'
              : 'green',
      'position': position,
      'description': description,
      'image': image,
    };
  }
}
