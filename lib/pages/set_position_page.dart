import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/pages/home_page.dart';
import 'package:guime/services/shared_preferences_helper.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:guime/widgets/custom_backbutton.dart';
import 'package:guime/widgets/custom_bottun.dart';
import 'package:guime/widgets/custom_snackbar.dart';

class SetPositionPage extends StatefulWidget {
  final PinType type;
  const SetPositionPage({super.key, required this.type});

  @override
  State<SetPositionPage> createState() => _SetPositionPageState();
}

class _SetPositionPageState extends State<SetPositionPage> {
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
  void initState() {
    super.initState();
    _determinePosition().then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _markers.clear();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (widget.type) {
      PinType.green => const Color(MyColors.lightGreen3),
      PinType.red => const Color(MyColors.lightRed3),
      PinType.blue => const Color(MyColors.lightBlue3)
    };

    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: GoogleMap(
                    myLocationEnabled: true,
                    markers: _markers,
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
                        _markers.clear();
                        _markers.add(
                          Marker(
                            markerId: MarkerId(position.toString()),
                            position: position,
                          ),
                        );
                      });
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        barrierColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 250,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  height: 200,
                                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(32),
                                      topRight: Radius.circular(32),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(26),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(MyColors.lightBeige),
                                            blurRadius: 4,
                                            spreadRadius: -0.1,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          const Text(
                                            'この地点を登録しますか？',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(MyColors.darkGrey),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              customButton(
                                                  color: const Color(MyColors.darkGrey),
                                                  child: const Center(
                                                      child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: Color(MyColors.beige),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 24),
                                                  )),
                                                  onTapped: () {
                                                    setState(() {
                                                      _markers.clear();
                                                    });
                                                    Navigator.pop(context);
                                                  }),
                                              customButton(
                                                  color: const Color(MyColors.darkGrey),
                                                  child: const Center(
                                                      child: Text(
                                                    'Save',
                                                    style: TextStyle(
                                                        color: Color(MyColors.beige),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 24),
                                                  )),
                                                  onTapped: () {
                                                    setState(() {
                                                      _savePosition(position.latitude, position.longitude);
                                                      _markers.clear();
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => const HomePage(),
                                                          ));
                                                    });
                                                  }),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                IgnorePointer(
                                  child: Opacity(
                                    opacity: 0.8,
                                    child: Image.asset(
                                      'assets/images/noise.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).then((_) {
                        setState(() {
                          _markers.clear();
                        });
                      });
                    },
                  ),
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
    ));
  }
}
