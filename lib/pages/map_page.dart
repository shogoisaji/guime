import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/widgets/custom_backbutton.dart';
import 'package:guime/widgets/loading_widget.dart';

class MapPage extends StatefulWidget {
  final Pin pin;
  const MapPage({super.key, required this.pin});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  GoogleMapController? _googleMapController;

  late LatLng _targetPosition;
  late LatLng _currentPosition;

  bool _visibleLoading = true;

  final ValueNotifier<bool> _loading = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _opacityController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacityAnimation = CurvedAnimation(parent: _opacityController, curve: Curves.easeInQuart);
    _loading.addListener(_loadingListener);
  }

  void _loadingListener() {
    if (!_loading.value) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        _opacityController.forward().whenComplete(() {
          _opacityController.reset();
          setState(() {
            _visibleLoading = false;
          });
        });
      });
    }
  }

  @override
  void dispose() {
    _loading.removeListener(_loadingListener);
    _opacityController.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

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
    if (!mounted) return;
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _loading.value = false;
    });
  }

  Future<Set<Marker>> _createMarker() async {
    final pinIndex = PinType.values.indexOf(widget.pin.type);
    _targetPosition = LatLng(widget.pin.position.latitude, widget.pin.position.longitude);
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/images/icon${pinIndex + 1}.png',
    );
    Set<Marker> markers = {
      Marker(
        markerId: MarkerId("target"),
        position: _targetPosition,
        icon: customIcon,
      ),
    };

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _loading.value
                ? Container()
                : FutureBuilder<Set<Marker>>(
                    future: _createMarker(),
                    builder: (BuildContext context, AsyncSnapshot<Set<Marker>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('エラーが発生しました'));
                      } else {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: GoogleMap(
                            myLocationEnabled: true,
                            markers: snapshot.data ?? <Marker>{},
                            mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition,
                              zoom: 15.0,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              if (!_mapController.isCompleted) {
                                _mapController.complete(controller);
                                _googleMapController = controller;
                              }
                            },
                          ),
                        );
                      }
                    },
                  ),
            _visibleLoading
                ?
                // Loading画面
                AnimatedBuilder(
                    animation: _opacityAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 1 - _opacityAnimation.value,
                        child: _visibleLoading
                            ? LoadingWidget(
                                type: widget.pin.type,
                                isAttention: true,
                                isCalibration: false,
                              )
                            : Container(),
                      );
                    },
                  )
                : Container(),
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
