import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guime/services/compass.dart';
import 'package:guime/services/map_service.dart';
import 'package:guime/widgets/compass_widget.dart';

import 'dart:math';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? controller;
  Position? position;
  StreamSubscription<Position>? positionStream;
  double? targetToAngle;

  final sampleCoordinate = const LatLng(34.731278, 135.597188);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameraController();
    startPositionStream();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    stopPositionStream();
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController();
    }
  }

  void startPositionStream() {
    print('startPositionStream');
    Geolocator.getPositionStream().listen(
      (Position position) {
        // ２点の座標から角度を計算
        print('position : ${position.latitude} ${position.longitude}');
        setState(() {
          targetToAngle = calculateBearing(
              position.latitude, position.longitude, sampleCoordinate.latitude, sampleCoordinate.longitude);
        });

        print('targetToAngle : $targetToAngle');
      },
    );
  }

  void stopPositionStream() {
    positionStream?.cancel();
  }

  // void _getPosition() async {

  //   position = await MapService().getCurrentPosition();
  //   print(position);
  //   final double angle = calculateBearing(position!.latitude, position!.longitude, 34.705029, 135.498414);
  //   print('angle : $angle');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _cameraPreviewWidget(),
          _buildCompass(targetToAngle),
          Column(
            children: [
              Expanded(
                flex: 7,
                child: Stack(
                  // fit: StackFit.expand,
                  children: [
                    // CompassWidget(),

                    // Positioned(top: 110, child: _cameraTogglesRowWidget())
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.blue,
                  child: Center(child: Text('Map')),
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: Text(
          'No camera found',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return CameraPreview(
        controller!,
      );
    }
  }

  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    void onChanged(CameraDescription? description) {
      if (description == null) {
        return;
      }

      print('onChanged${description.name}');
      _initializeCameraController();
    }

    if (widget.cameras.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        showInSnackBar('No camera found.');
      });
      return const Text('None');
    } else {
      for (final CameraDescription cameraDescription in widget.cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(Icons.camera_alt),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: onChanged,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCameraException(CameraException e) {
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  Future<void> _initializeCameraController() async {
    final CameraController cameraController = CameraController(
      widget.cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }
}

double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
  var lat1Rad = _toRadians(lat1);
  var lon1Rad = _toRadians(lon1);
  var lat2Rad = _toRadians(lat2);
  var lon2Rad = _toRadians(lon2);

  var deltaLon = lon2Rad - lon1Rad;

  var y = sin(deltaLon) * cos(lat2Rad);
  var x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(deltaLon);

  var bearing = atan2(y, x);
  bearing = _toDegrees(bearing);
  bearing = (bearing + 360) % 360;

  return bearing;
}

double _toRadians(double degree) {
  return degree * pi / 180;
}

double _toDegrees(double radian) {
  return radian * 180 / pi;
}

class MyCustomPainter extends CustomPainter {
  final double strokeWidth;
  const MyCustomPainter({required this.strokeWidth});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..strokeWidth = strokeWidth * 2
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, 0);
    final end = Offset(size.width / 2, size.height);
    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(MyCustomPainter old) {
    return old.strokeWidth != strokeWidth;
  }
}

Widget _buildCompass(double? targetToAngle) {
  double calculateAngleDifference(double? angle1, double? angle2) {
    if (angle1 == null || angle2 == null) return 0;
    double difference = angle2 - angle1;
    while (difference < -180) difference += 360;
    while (difference > 180) difference -= 360;
    return difference;
  }

  return StreamBuilder<CompassEvent>(
    stream: FlutterCompass.events,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error reading heading: ${snapshot.error}');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      double? direction = snapshot.data!.heading;
      if (direction == null) {
        return const Center(
          child: Text("Device does not have sensors !"),
        );
      }
      print('direction : $direction targetToAngle : $targetToAngle');

      final double angleDifference = calculateAngleDifference(direction, targetToAngle);
      print('angleDifference : $angleDifference');

      return CustomPaint(painter: MyCustomPainter(strokeWidth: angleDifference));

      // Container(
      //   padding: const EdgeInsets.all(16.0),
      //   alignment: Alignment.center,
      //   decoration: const BoxDecoration(
      //     shape: BoxShape.circle,
      //   ),
      //   child: Text(
      //     '${direction.toStringAsFixed(0)}°',
      //     style: const TextStyle(fontSize: 100, color: Colors.red, fontWeight: FontWeight.bold),
      //   ),
      // );
    },
  );
}
