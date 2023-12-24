// import 'package:flutter/material.dart';
// import 'package:flutter_compass/flutter_compass.dart';
// import 'package:permission_handler/permission_handler.dart';

// class Compass {
//   Future<double?> getDirection() async {
//     Permission.locationWhenInUse.status.then((status) {
//       if (status != PermissionStatus.granted) return;
//     });
//     double? data;
//     FlutterCompass.events!.listen((event) {
//       data = event.heading;
//     });
//     print(data);
//     return data;
//   }
// }
