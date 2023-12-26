import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/services/shared_preferences_helper.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:guime/widgets/custom_snackbar.dart';

class SetPositionWidget extends StatefulWidget {
  final PinType type;
  const SetPositionWidget({super.key, required this.type});

  @override
  State<SetPositionWidget> createState() => _SetPositionWidgetState();
}

class _SetPositionWidgetState extends State<SetPositionWidget> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  late LatLng _currentPosition;
  final Set<Marker> _markers = {};
  bool _loading = true;

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _savePosition(double latitude, double longitude) async {
    final Pin pin = Pin(
      type: widget.type,
      position: Position(
        latitude: latitude,
        longitude: longitude,
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
      ),
      description: '',
      image: '',
    );

    final saveType = await SharedPreferencesHelper().savePin(pin);
    ScaffoldMessenger.of(context).showSnackBar(
      customSnackbar('$saveTypeを登録しました', Color(MyColors.darkPurple)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      child: GoogleMap(
        myLocationEnabled: true,
        // markers: snapshot.data ?? Set<Marker>(),
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 15.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          if (!_mapController.isCompleted) {
            _mapController.complete(controller);
          }
        },
        onLongPress: (LatLng position) {
          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId(position.toString()),
                position: position,
              ),
            );
          });
        },
      ),
    );
  }
}
