import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/services/location_permission_handler.dart';
import 'package:guime/services/shared_preferences_helper.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:guime/widgets/custom_backbutton.dart';
import 'package:guime/widgets/custom_bottun.dart';
import 'package:guime/widgets/custom_snackbar.dart';
import 'package:guime/widgets/loading_widget.dart';

class SetPositionPage extends StatefulWidget {
  final PinType type;
  const SetPositionPage({super.key, required this.type});

  @override
  State<SetPositionPage> createState() => _SetPositionPageState();
}

class _SetPositionPageState extends State<SetPositionPage> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  bool _visibleLoading = true;

  final ValueNotifier<bool> _loading = ValueNotifier(true);

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

  Future<String> _savePosition(double latitude, double longitude) async {
    final Pin pin = Pin(
      type: widget.type,
      position: Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now().toLocal(),
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
    return saveType;
  }

  @override
  void initState() {
    super.initState();
    _opacityController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacityAnimation = CurvedAnimation(parent: _opacityController, curve: Curves.easeInQuart);
    _loading.addListener(_loadingListener);

    _determinePosition();
  }

  void _loadingListener() {
    if (!_loading.value) {
      Future.delayed(const Duration(milliseconds: 500), () {
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
    _opacityController.dispose();
    _loading.removeListener(_loadingListener);
    _markers.clear();
    super.dispose();
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
      top: false,
      child: _currentPosition == null
          ? const SizedBox.shrink()
          : Stack(
              children: [
                _loading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: GoogleMap(
                          myLocationEnabled: true,
                          markers: _markers,
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                            target: _currentPosition!,
                            zoom: 16.0,
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
                                                Text(
                                                  AppLocalizations.of(context)!.save_check,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(MyColors.darkGrey),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    customButton(
                                                        color: const Color(MyColors.darkGrey),
                                                        child: Center(
                                                            child: Text(
                                                          AppLocalizations.of(context)!.cancel,
                                                          style: TextStyle(
                                                              color: const Color(MyColors.beige),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize:
                                                                  Localizations.localeOf(context).languageCode == 'ja'
                                                                      ? 18
                                                                      : 24),
                                                        )),
                                                        width: 120,
                                                        onTapped: () {
                                                          setState(() {
                                                            _markers.clear();
                                                          });
                                                          Navigator.pop(context);
                                                        }),
                                                    customButton(
                                                        color: const Color(MyColors.darkGrey),
                                                        child: Center(
                                                            child: Text(
                                                          AppLocalizations.of(context)!.save,
                                                          style: const TextStyle(
                                                              color: Color(MyColors.beige),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 24),
                                                        )),
                                                        width: 120,
                                                        onTapped: () async {
                                                          final color = switch (widget.type) {
                                                            PinType.green => const Color(MyColors.green),
                                                            PinType.red => const Color(MyColors.red),
                                                            PinType.blue => const Color(MyColors.blue)
                                                          };
                                                          final saveType = await _savePosition(
                                                              position.latitude, position.longitude);
                                                          _markers.clear();
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(customSnackbar(
                                                              Localizations.localeOf(context).languageCode == 'ja'
                                                                  ? '${saveType.toUpperCase()}${AppLocalizations.of(context)!.saved_location}'
                                                                  : '${AppLocalizations.of(context)!.saved_location}${saveType.toUpperCase()}',
                                                              color,
                                                            ));
                                                            Navigator.pushNamed(context, '/');
                                                          }
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
                Align(
                  alignment: const Alignment(0, 0.83),
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 36),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            AppLocalizations.of(context)!.point_register,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(MyColors.darkBlue),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: 0.8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              'assets/images/noise.png',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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
                                    type: widget.type,
                                    isAttention: false,
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
    ));
  }
}
