// import 'package:flutter/material.dart';
// import 'package:flutter_compass/flutter_compass.dart';
// import 'package:guime/theme/color_theme.dart';
// import 'package:permission_handler/permission_handler.dart';

// class CompassWidget extends StatefulWidget {
//   const CompassWidget({super.key});

//   @override
//   State<CompassWidget> createState() => _CompassWidgetState();
// }

// class _CompassWidgetState extends State<CompassWidget> {
//   bool _hasPermissions = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchPermissionStatus();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Builder(builder: (context) {
//         if (_hasPermissions) {
//           return Column(
//             children: <Widget>[
//               SizedBox(height: 150),
//               Expanded(child: _buildCompass()),
//             ],
//           );
//         } else {
//           return _buildPermissionSheet();
//         }
//       }),
//     );
//   }

//   Widget _buildCompass() {
//     return StreamBuilder<CompassEvent>(
//       stream: FlutterCompass.events,
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error reading heading: ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         double? direction = snapshot.data!.heading;

//         if (direction == null) {
//           return const Center(
//             child: Text("Device does not have sensors !"),
//           );
//         }

//         return Container(
//           padding: const EdgeInsets.all(16.0),
//           alignment: Alignment.center,
//           decoration: const BoxDecoration(
//             shape: BoxShape.circle,
//           ),
//           child: Text(
//             '${direction.toStringAsFixed(0)}°',
//             style: const TextStyle(fontSize: 100, color: Colors.red, fontWeight: FontWeight.bold),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPermissionSheet() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ElevatedButton(
//             child: const Text('コンパスを有効にする'),
//             onPressed: () {
//               Permission.locationWhenInUse.serviceStatus.isEnabled.then((isEnabled) {
//                 if (isEnabled) {
//                   // 位置情報サービスが有効な場合、許可をリクエスト
//                   Permission.locationWhenInUse.request().then((ignored) {
//                     _fetchPermissionStatus();
//                   });
//                 } else {
//                   // 位置情報サービスが無効な場合、ユーザーにその旨を通知
//                   ScaffoldMessenger.of(context).showSnackBar(
//                      const SnackBar(
//                       content: Center(
//                         child: Text('位置情報を有効にして下さい',
//                             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
//                       ),
//                       backgroundColor:   Color(MyColors.red),
//                       duration: Duration(seconds: 2),
//                     ),
//                   );
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _fetchPermissionStatus() {
//     Permission.locationWhenInUse.status.then((status) {
//       if (mounted) {
//         setState(() => _hasPermissions = status == PermissionStatus.granted);
//       }
//     });
//   }
// }
