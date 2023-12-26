import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:guime/widgets/custom_backbutton.dart';
import 'package:guime/widgets/lower_pattern_painter.dart';
import 'package:intl/intl.dart';

import 'dart:math';
import 'package:rive/rive.dart';
import 'package:guime/widgets/custom_snackbar.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Pin pin;
  const CameraPage({super.key, required this.cameras, required this.pin});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? controller;
  Position? position;
  StreamSubscription<Position>? positionStream;
  double? targetToAngle;
  double? targetToDistance;

  SMIInput<double>? _angle;
  SMIInput<double>? _scaleX;
  SMIInput<double>? _scaleY;

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'state',
    );
    artboard.addController(controller!);
    _scaleX = controller.findInput<double>('scaleX') as SMINumber;
    _scaleY = controller.findInput<double>('scaleY') as SMINumber;
    _angle = controller.findInput<double>('angle') as SMINumber;
  }

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
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen(
      (Position position) {
        // ２点の座標から角度を計算
        setState(() {
          targetToAngle = calculateBearing(
              position.latitude, position.longitude, widget.pin.position.latitude, widget.pin.position.longitude);
          targetToDistance = calculateDistance(
              position.latitude, position.longitude, widget.pin.position.latitude, widget.pin.position.longitude);
        });
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
    final List<Color> _backgroundColors = switch (widget.pin.type) {
      PinType.green => [
          const Color(MyColors.lightGreen1),
          const Color(MyColors.lightGreen2),
          const Color(MyColors.lightGreen3),
        ],
      PinType.blue => [
          const Color(MyColors.lightBlue1),
          const Color(MyColors.lightBlue2),
          const Color(MyColors.lightBlue3),
        ],
      PinType.red => [
          const Color(MyColors.lightRed1),
          const Color(MyColors.lightRed2),
          const Color(MyColors.lightRed3),
        ],
    };
    final double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _cameraPreviewWidget(),
          Align(
            alignment: Alignment(0, 01.3),
            child: CustomPaint(painter: LowerPatternPainter(width: w, color: _backgroundColors[0])),
          ),
          Align(
            alignment: Alignment(0, 1.5),
            child: CustomPaint(painter: LowerPatternPainter(width: w, color: _backgroundColors[1])),
          ),
          Align(
            alignment: Alignment(0, 1.7),
            child: CustomPaint(painter: LowerPatternPainter(width: w, color: _backgroundColors[2])),
          ),
          // 距離の表示
          Align(
            alignment: Alignment(0, -0.5),
            child: Container(
              height: 100,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Colors.black.withOpacity(0.6),
              ),
              child: Center(
                child: Text(
                  targetToDistance != null ? targetToDistance!.toStringAsFixed(0) + 'm' : '',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('登録日時', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(
                DateFormat('yyyy.MM.dd HH:mm').format(widget.pin.position.timestamp),
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
            ],
          ),
          Align(
            alignment: Alignment(0, 0.47),
            child: StreamBuilder<CompassEvent>(
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
                // print('direction : $direction targetToAngle : $targetToAngle');

                final double angleDifference = calculateAngleDifference(direction, targetToAngle);
                // print('angleDifference : $angleDifference');
                if (angleDifference < 0) {
                  print('angleDifference : ${360 + angleDifference / 3.6}');
                  _angle?.value = (360 + angleDifference) / 3.6;
                } else {
                  _angle?.value = angleDifference / 3.6;
                }

                _scaleY?.value = 100 - (angleDifference / 1.8).abs();
                _scaleX?.value = 0;

                return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 500,
                    child: RiveAnimation.asset('assets/riv/compass.riv', fit: BoxFit.contain, onInit: _onRiveInit));
              },
            ),
          ),
          Positioned(
            top: 60,
            left: 10,
            child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: customBackButton()),
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

  double calculateAngleDifference(double? angle1, double? angle2) {
    if (angle1 == null || angle2 == null) return 0;
    double difference = angle2 - angle1;
    while (difference < -180) difference += 360;
    while (difference > 180) difference -= 360;
    return difference;
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

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  var lat1Rad = _toRadians(lat1);
  var lon1Rad = _toRadians(lon1);
  var lat2Rad = _toRadians(lat2);
  var lon2Rad = _toRadians(lon2);

  var deltaLat = lat2Rad - lat1Rad;
  var deltaLon = lon2Rad - lon1Rad;

  var a = sin(deltaLat / 2) * sin(deltaLat / 2) + cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);
  var c = 2 * atan2(sqrt(a), sqrt(1 - a));

  const double earthRadius = 6371000; // 地球の半径（メートル）
  var distance = earthRadius * c;

  return distance;
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
