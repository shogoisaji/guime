import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/services/location_permission_handler.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:guime/widgets/custom_backbutton.dart';
import 'package:guime/widgets/custom_snackbar.dart';
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
  LatLng? _currentPosition;

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
    final isLocationGranted = await LocationPermissionsHandler().isGranted;
    if (!isLocationGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackbar(
            AppLocalizations.of(context)!.location_permission,
            const Color(MyColors.red),
          ),
        );
      }
      _currentPosition = null;
      return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _loading.value = false;
      });
    }
  }

  Future<Set<Marker>> _createMarker() async {
    final pinIndex = PinType.values.indexOf(widget.pin.type);
    _targetPosition = LatLng(widget.pin.position.latitude, widget.pin.position.longitude);
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      Platform.isIOS ? 'assets/images/icon${pinIndex + 1}.png' : 'assets/images/icon${pinIndex + 1}_a.png',
    );
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId("target"),
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
        top: false,
        child: _currentPosition == null
            ? const SizedBox.shrink()
            : Stack(
                children: [
                  _loading.value
                      ? Container()
                      : FutureBuilder<Set<Marker>>(
                          future: _createMarker(),
                          builder: (BuildContext context, AsyncSnapshot<Set<Marker>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(child: Text('Error'));
                            } else {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: GoogleMap(
                                  myLocationEnabled: true,
                                  markers: snapshot.data ?? <Marker>{},
                                  mapType: MapType.normal,
                                  initialCameraPosition: CameraPosition(
                                    target: _currentPosition!,
                                    zoom: 16.0,
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
                  SafeArea(
                    child: Stack(
                      children: [
                        Positioned(
                          top: 25,
                          left: 15,
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: customBackButton()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
