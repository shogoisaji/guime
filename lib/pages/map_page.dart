import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:guime/widgets/custom_backbutton.dart';

class MapPage extends StatefulWidget {
  final Pin pin;
  const MapPage({super.key, required this.pin});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  late LatLng _targetPosition;
  late LatLng _currentPosition;

  late bool _loading;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _determinePosition();
  }

//   Future _searchLocation() async {
//   final Position position = await _determinePosition();
//   print(position.latitude);
//   print(position.longitude);
// }

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
      _loading = false;
    });
  }

  Future<Set<Marker>> _createMarker() async {
    _targetPosition = LatLng(widget.pin.position.latitude, widget.pin.position.longitude);
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/images/icon1.png',
    );
    Set<Marker> markers = {
      Marker(
        markerId: MarkerId("target"),
        position: _targetPosition,
        icon: customIcon,
      ),
      Marker(
        markerId: MarkerId("current"),
        position: _currentPosition,
      ),
    };

    // マーカーが全て表示されるようにビューポートを調整
    LatLngBounds bounds;
    if (_currentPosition.latitude > _targetPosition.latitude &&
        _currentPosition.longitude > _targetPosition.longitude) {
      bounds = LatLngBounds(southwest: _targetPosition, northeast: _currentPosition);
    } else {
      bounds = LatLngBounds(southwest: _currentPosition, northeast: _targetPosition);
    }
    _controller.future.then((controller) => controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50)));

    return markers;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _loading
                ? Center(
                    child: Container(
                        width: 100,
                        height: 100,
                        padding: const EdgeInsets.all(15),
                        child: const CircularProgressIndicator()),
                  )
                : FutureBuilder<Set<Marker>>(
                    future: _createMarker(),
                    builder: (BuildContext context, AsyncSnapshot<Set<Marker>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('エラーが発生しました'));
                      } else {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: GoogleMap(
                            myLocationEnabled: true,
                            markers: snapshot.data ?? Set<Marker>(),
                            mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition,
                              zoom: 15.0,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                          ),
                        );
                      }
                    },
                  ),
            Positioned(
              top: 30,
              left: 10,
              child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: customBackButton()),
            ),
          ],
        ),
      ),
    );
  }
}
