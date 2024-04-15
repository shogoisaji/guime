import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:guime/animations/title_animation.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/pages/camera_page.dart';
import 'package:guime/pages/custom_license_page.dart';
import 'package:guime/pages/map_page.dart';
import 'package:guime/pages/set_position_page.dart';
import 'package:guime/services/camera_permission_handler.dart';
import 'package:guime/services/location_permission_handler.dart';
import 'package:guime/services/shared_preferences_helper.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:guime/widgets/custom_bottun.dart';
import 'package:guime/widgets/custom_snackbar.dart';
import 'package:guime/widgets/lower_pattern_painter.dart';

class HomePage extends StatefulWidget {
  final Function onLanguageChanged;
  const HomePage({super.key, required this.onLanguageChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  final PageController _pageController = PageController(viewportFraction: 0.38, initialPage: 1);
  PinType _pinType = PinType.blue;
  double _centerLightOpacity = 1.0;
  final List<double> _pinScale = [0.75, 1.0, 0.75];
  final List<double> _pinAngles = [-0.3, 0.0, 0.3];
  final List<Offset> _pinTranslates = [const Offset(50, 50), const Offset(0, 0), const Offset(-50, 50)];
  late List<CameraDescription> cameras;
  Map<String, Pin?> _pins = {};
  double _dragPositionY = 0.0;
  bool _isToggleOn = false;
  bool _isFeedback = false;
  bool _savingCurrentPosition = false;

  Widget _setDisplayText() {
    if (_savingCurrentPosition) {
      return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
    } else if (_isToggleOn) {
      return Text(
        AppLocalizations.of(context)!.release_and_save,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(MyColors.darkGrey),
        ),
      );
    } else {
      return Text(
        _pins[_pinType.toString().split('.')[1]] != null
            ? DateFormat('yyyy.MM.dd HH:mm').format(_pins[_pinType.toString().split('.')[1]]!.position.timestamp)
            : '-',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(MyColors.darkGrey),
        ),
      );
    }
  }

// スクロールに応じて状態を変更する
  void _updateStateOnScroll() {
    // pin transform
    if (_pageController.page != null) {
      if (_pageController.page! ~/ 1 == 1) {
        _pinScale[1] = 1 - (_pageController.page! % 1) / 4;
        _pinScale[2] = (_pageController.page! % 1) / 4 + 0.75;
        _pinAngles[1] = -(_pageController.page! % 1) / 3;
        _pinAngles[2] = (1 - (_pageController.page! % 1)) / 3;
        _pinTranslates[1] = Offset((_pageController.page! % 1) * 50, (_pageController.page! % 1) * 50);
        _pinTranslates[2] = Offset(-50 + (_pageController.page! % 1) * 50, 50 - (_pageController.page! % 1) * 50);
      }
      if (_pageController.page! ~/ 1 == 0) {
        _pinScale[0] = 1 - (_pageController.page! % 1) / 4;
        _pinScale[1] = (_pageController.page! % 1) / 4 + 0.75;
        _pinAngles[0] = -(_pageController.page! % 1) / 3;
        _pinAngles[1] = (1 - (_pageController.page! % 1)) / 3;
        _pinTranslates[0] = Offset((_pageController.page! % 1) * 50, (_pageController.page! % 1) * 50);
        _pinTranslates[1] = Offset(-50 + (_pageController.page! % 1) * 50, 50 - (_pageController.page! % 1) * 50);
      }
    }
    if (_pageController.hasClients) {
      setState(() {
        // 中央の光の透明度を更新
        _centerLightOpacity = 2 * ((_pageController.page! % 1) - 0.5).abs();

        // スクロールに応じてピンの色を更新
        switch ((_pageController.page! + 0.5) ~/ 1) {
          case 0:
            _pinType = PinType.green;
            break;
          case 1:
            _pinType = PinType.blue;
            break;
          case 2:
            _pinType = PinType.red;
            break;
        }
      });
    }
  }

  void _initCamera() async {
    cameras = await availableCameras();
  }

  Future<String?> _saveCurrentPosition() async {
    final isLocationGranted = await LocationPermissionsHandler().isGranted;
    if (isLocationGranted) {
      final Position position = await Geolocator.getCurrentPosition();
      final DateTime timestampJST = position.timestamp.toLocal();
      final Position positionJST = Position(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: timestampJST,
        accuracy: position.accuracy,
        altitude: position.altitude,
        heading: position.heading,
        speed: position.speed,
        speedAccuracy: position.speedAccuracy,
        floor: position.floor,
        isMocked: position.isMocked,
        altitudeAccuracy: position.altitudeAccuracy,
        headingAccuracy: position.headingAccuracy,
      );
      final saveType = await SharedPreferencesHelper().savePin(
        Pin(
          type: _pinType,
          position: positionJST,
          description: '',
          image: '',
        ),
      );
      return saveType;
    }
    return null;
  }

  Future<void> _loadAllPin() async {
    final Map<String, Pin?> pins = await SharedPreferencesHelper().loadAllPin();
    setState(() {
      _pins = pins;
    });
  }

  @override
  initState() {
    super.initState();
    LocationPermissionsHandler().request();
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animationController.addListener(() {
      setState(() {
        _dragPositionY = _animationController.value * 110;
      });
    });
    _initCamera();
    _pageController.addListener(_updateStateOnScroll);
    _loadAllPin();
  }

  void _resetToggle() {
    _animationController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    setState(() {
      _isToggleOn = false;
      _dragPositionY = _animationController.value * 110;
    });
  }

  @override
  dispose() {
    _pageController.removeListener(_updateStateOnScroll);
    _pageController.dispose();
    TextEditingController().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width > 500 ? 500 : MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    final List<Color> backgroundColors = switch (_pinType) {
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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(MyColors.beige),
      drawer: Drawer(
        backgroundColor: const Color(MyColors.beige),
        width: w * 0.6,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Image.asset(
                'assets/images/header.png',
                fit: BoxFit.fill,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Color(MyColors.darkBlue)),
              title: const Text('Licenses', style: TextStyle(color: Color(MyColors.darkBlue))),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomLicensePage()));
              },
            ),
            ListTile(
              titleAlignment: ListTileTitleAlignment.top,
              leading: const Icon(Icons.translate, color: Color(MyColors.darkBlue)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Language', style: TextStyle(color: Color(MyColors.darkBlue))),
                  const SizedBox(height: 8),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(MyColors.darkBlue), width: 2),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              widget.onLanguageChanged('ja');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Localizations.localeOf(context).languageCode == 'ja'
                                      ? Icons.radio_button_checked
                                      : Icons.circle_outlined,
                                  color: const Color(MyColors.darkBlue),
                                ),
                                const Expanded(
                                    child:
                                        Center(child: Text('日本語', style: TextStyle(color: Color(MyColors.darkBlue))))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              widget.onLanguageChanged('en');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Localizations.localeOf(context).languageCode == 'en'
                                      ? Icons.radio_button_checked
                                      : Icons.circle_outlined,
                                  color: const Color(MyColors.darkBlue),
                                ),
                                const Expanded(
                                    child: Center(
                                        child: Text('English', style: TextStyle(color: Color(MyColors.darkBlue))))),
                              ],
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
              width: w,
              height: h,
              child:
                  CustomPaint(painter: LowerPatternPainter(width: w, color: backgroundColors[0], positionY: h * 0.65))),
          SizedBox(
              width: w,
              height: h,
              child:
                  CustomPaint(painter: LowerPatternPainter(width: w, color: backgroundColors[1], positionY: h * 0.75))),
          SizedBox(
              width: w,
              height: h,
              child:
                  CustomPaint(painter: LowerPatternPainter(width: w, color: backgroundColors[2], positionY: h * 0.85))),
          Align(
              alignment: const Alignment(0, -1.4),
              child: Opacity(
                opacity: _centerLightOpacity,
                child: Container(
                  width: w * 0.8,
                  height: w * 0.8,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ],
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      focal: const Alignment(-0.2, -0.1),
                      radius: 0.6,
                      stops: const [0.1, 1.0],
                      colors: [_pinType.color, Colors.transparent],
                    ),
                  ),
                ),
              )),
          Align(
            alignment: const Alignment(0.0, -1.6),
            child: TitleAnimation(width: w),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: w * 0.85,
                  height: 235,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              icon: const Icon(Icons.menu, color: Color(MyColors.darkGrey), size: 28)),
                          SizedBox(
                            width: 80,
                            child: Text(
                              AppLocalizations.of(context)!.current_position,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                                color: Color(MyColors.darkGrey),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    final isLocationGranted = await LocationPermissionsHandler().isGranted;
                                    if (!isLocationGranted) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          customSnackbar(
                                            AppLocalizations.of(context)!.location_permission,
                                            const Color(MyColors.red),
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SetPositionPage(
                                                  type: _pinType,
                                                )),
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(MyColors.darkGrey),
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.7),
                                          spreadRadius: 0.5,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: Container(
                                      width: w * 0.6,
                                      height: w * 0.15,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.3),
                                            spreadRadius: -0.1,
                                            blurRadius: 5,
                                            offset: const Offset(0, -3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.save_on_map,
                                          style: TextStyle(
                                            fontSize: Localizations.localeOf(context).languageCode == 'ja' ? 22 : 24,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(MyColors.lightBeige),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: w * 0.6,
                                  height: w * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: _isToggleOn ? const Color(MyColors.darkOrange) : Colors.black26,
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _isToggleOn
                                              ? const Color(MyColors.orange)
                                              : const Color(MyColors.lightBeige),
                                          blurRadius: 4,
                                          spreadRadius: -0.1,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Center(child: _setDisplayText()),
                                  ),
                                )
                              ],
                            ),
                            // current position save toggle
                            Container(
                              width: 70,
                              height: double.infinity,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: _isToggleOn ? const Color(MyColors.darkOrange) : Colors.black26,
                              ),
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          _isToggleOn ? const Color(MyColors.orange) : const Color(MyColors.lightBeige),
                                      blurRadius: 4,
                                      spreadRadius: -0.1,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                        top: 90,
                                        left: 12.5,
                                        child: Opacity(
                                          opacity: 1 - _animationController.value,
                                          child: Image.asset(
                                            'assets/images/arrow.png',
                                            width: 35,
                                            height: 40,
                                            fit: BoxFit.fill,
                                          ),
                                        )),
                                    Positioned(
                                      top: 5 + _dragPositionY,
                                      left: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(MyColors.darkGrey),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.7),
                                              spreadRadius: 0.5,
                                              blurRadius: 3,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.3),
                                                spreadRadius: -0.1,
                                                blurRadius: 5,
                                                offset: const Offset(0, -3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5 + _dragPositionY,
                                      left: 5,
                                      child: Draggable(
                                        onDragEnd: (details) async {
                                          if (_isToggleOn) {
                                            final isLocationGranted = await LocationPermissionsHandler().isGranted;
                                            if (!isLocationGranted) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  customSnackbar(
                                                    AppLocalizations.of(context)!.location_permission,
                                                    const Color(MyColors.red),
                                                  ),
                                                );
                                              }
                                              setState(() {
                                                _savingCurrentPosition = false;
                                              });
                                              _resetToggle();
                                              return;
                                            }
                                            setState(() {
                                              _savingCurrentPosition = true;
                                            });
                                            final String? saveType = await _saveCurrentPosition();
                                            if (saveType != null) {
                                              _loadAllPin();
                                              final color = switch (_pinType) {
                                                PinType.green => const Color(MyColors.green),
                                                PinType.red => const Color(MyColors.red),
                                                PinType.blue => const Color(MyColors.blue)
                                              };
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  customSnackbar(
                                                    Localizations.localeOf(context).languageCode == 'ja'
                                                        ? '${saveType.toUpperCase()}${AppLocalizations.of(context)!.saved_location}'
                                                        : '${AppLocalizations.of(context)!.saved_location}${saveType.toUpperCase()}',
                                                    color,
                                                  ),
                                                );
                                              }
                                            } else if (saveType == null) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  customSnackbar(
                                                    AppLocalizations.of(context)!.location_error,
                                                    const Color(MyColors.red),
                                                  ),
                                                );
                                              }
                                            }
                                            setState(() {
                                              _savingCurrentPosition = false;
                                            });
                                          }
                                          _savingCurrentPosition = false;
                                          _resetToggle();
                                        },
                                        onDragUpdate: (details) {
                                          _animationController.value = _dragPositionY / 110;
                                          setState(() {
                                            _dragPositionY += details.delta.dy;
                                            if (_dragPositionY > 110) _dragPositionY = 110;
                                            if (_dragPositionY < 0) _dragPositionY = 0;
                                            if (_dragPositionY > 100) {
                                              _isToggleOn = true;
                                              if (_isFeedback) {
                                                HapticFeedback.heavyImpact();
                                                _isFeedback = false;
                                              }
                                            } else {
                                              _isToggleOn = false;
                                              _isFeedback = true;
                                            }
                                          });
                                        },
                                        feedback: Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.transparent,
                                        ),
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: h / 4,
                  child: PageView.builder(
                    physics: const ClampingScrollPhysics(),
                    controller: _pageController,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Align(
                        child: Transform.scale(
                          scale: 1.1 * _pinScale[index],
                          child: Transform.translate(
                            offset: _pinTranslates[index],
                            child: Transform.rotate(
                              angle: _pinAngles[index],
                              child: Image.asset(
                                'assets/images/pin${index + 1}.png',
                                height: 400,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  height: w * 0.4,
                  width: w * 0.9,
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.black.withOpacity(0.2),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.find,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(MyColors.darkGrey),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            customButton(
                                child: const Icon(Icons.map, color: Color(MyColors.lightBeige), size: 48),
                                color: const Color(MyColors.darkGrey),
                                onTapped: () async {
                                  final isLocationGranted = await LocationPermissionsHandler().isGranted;
                                  if (!isLocationGranted) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        customSnackbar(
                                          AppLocalizations.of(context)!.location_permission,
                                          const Color(MyColors.red),
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                  final Pin? pin = _pins[_pinType.toString().split('.')[1]];
                                  if (context.mounted) {
                                    if (pin == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        customSnackbar(
                                          AppLocalizations.of(context)!.no_register,
                                          const Color(MyColors.red),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapPage(
                                          pin: pin,
                                        ),
                                      ),
                                    );
                                  }
                                }),
                            customButton(
                                child: const Icon(Icons.camera_alt, color: Color(MyColors.lightBeige), size: 48),
                                color: const Color(MyColors.darkGrey),
                                onTapped: () async {
                                  await CameraPermissionsHandler().request();
                                  final isLocationGranted = await LocationPermissionsHandler().isGranted;
                                  if (!isLocationGranted) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        customSnackbar(
                                          AppLocalizations.of(context)!.location_permission,
                                          const Color(MyColors.red),
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                  final isCameraGranted = await CameraPermissionsHandler().isGranted;
                                  if (!isCameraGranted) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        customSnackbar(
                                          AppLocalizations.of(context)!.camera_permission,
                                          const Color(MyColors.red),
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                  if (cameras.isEmpty) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        customSnackbar(
                                          AppLocalizations.of(context)!.camera_error,
                                          const Color(MyColors.red),
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                  final Pin? pin = _pins[_pinType.toString().split('.')[1]];
                                  if (context.mounted) {
                                    if (pin == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        customSnackbar(
                                          AppLocalizations.of(context)!.no_register,
                                          const Color(MyColors.red),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CameraPage(
                                          cameras: cameras,
                                          pin: pin,
                                        ),
                                      ),
                                    );
                                  }
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          IgnorePointer(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/noise.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
