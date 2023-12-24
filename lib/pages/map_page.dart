import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  late LatLng _initialPosition;

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
      _initialPosition = LatLng(position.latitude, position.longitude);
      _loading = false;
      print(_initialPosition);
    });
  }

  Set<Marker> _createMarker() {
    _initialPosition = LatLng(34.705029, 135.498414);
    // _initialPosition =
    //     LatLng(widget.position!.latitude, widget.position!.longitude);
    return {
      Marker(
        markerId: MarkerId("marker_1"),
        position: LatLng(_initialPosition.latitude, _initialPosition.longitude),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Map'),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Go to Camera'),
            ),
            _loading
                ? const CircularProgressIndicator()
                : Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: GoogleMap(
                      markers: _createMarker(),
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: _initialPosition,
                        zoom: 12.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
