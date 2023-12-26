import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guime/animations/title_animation.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/pages/camera_page.dart';
import 'package:guime/pages/map_page.dart';
import 'package:guime/pages/set_position_page.dart';
import 'package:guime/services/shared_preferences_helper.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:guime/widgets/custom_bottun.dart';
import 'package:guime/widgets/custom_snackbar.dart';
import 'package:guime/widgets/lower_pattern_painter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final PageController _pageController = PageController(viewportFraction: 0.45, initialPage: 1);
  PinType _pinType = PinType.blue;
  double _centerLightOpacity = 1.0;
  List<double> _sizeRates = [1.0, 1.0, 1.0];
  late List<CameraDescription> cameras;

  Map<String, Pin?> _pins = {};

  double _dragPositionY = 0.0;

  bool _isToggleOn = false;

// スクロールに応じて状態を変更する
  void _updateStateOnScroll() {
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
// // スクロールに応じて状態を変更する
//   void _updateStateOnScroll() {
//     if (_pageController.hasClients) {
//       setState(() {
//         // 中央の光の透明度を更新
//         _centerLightOpacity = 2 * ((_pageController.page! % 1) - 0.5).abs();

//         // スクロールに応じてピンの色を更新
//         switch ((_pageController.page! + 0.5) ~/ 1) {
//           case 0:
//             _pinType = PinType.green;
//             break;
//           case 1:
//             _pinType = PinType.blue;
//             break;
//           case 2:
//             _pinType = PinType.red;
//             break;
//         }
//       });
//     }
//   }

  void _initCamera() async {
    cameras = await availableCameras();
  }

  Future<String?> _setCurrentPosition() async {
    final PermissionStatus permission = await Permission.location.request();
    if (permission == PermissionStatus.granted) {
      final Position position = await Geolocator.getCurrentPosition();
      final saveType = await SharedPreferencesHelper().savePin(
        Pin(
          type: _pinType,
          position: position,
          description: '',
          image: '',
        ),
      );
      return saveType;
    }
    return null;
  }

  @override
  initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animationController.addListener(() {
      setState(() {
        _dragPositionY = _animationController.value * 110;
      });
    });
    _initCamera();
    _pageController.addListener(_updateStateOnScroll);
    SharedPreferencesHelper().loadAllPin().then((value) {
      print(value);
      setState(() {
        _pins = value;
      });
    });
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

    final List<Color> _backgroundColors = switch (_pinType) {
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
      backgroundColor: Color(MyColors.beige),
      body: Stack(
        children: [
          Align(
            alignment: Alignment(0, 01.1),
            child: CustomPaint(painter: LowerPatternPainter(width: w, color: _backgroundColors[0])),
          ),
          Align(
            alignment: Alignment(0, 1.3),
            child: CustomPaint(painter: LowerPatternPainter(width: w, color: _backgroundColors[1])),
          ),
          Align(
            alignment: Alignment(0, 1.5),
            child: CustomPaint(painter: LowerPatternPainter(width: w, color: _backgroundColors[2])),
          ),
          Align(
              alignment: const Alignment(0, -1.2),
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
          const Align(
            alignment: Alignment(0.0, -1.22),
            child: TitleAnimation(),
          ),
          SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Align(
                  alignment: Alignment(0.9, -0.55),
                  child: Text(
                    'CURRENT\nPOSITION',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.1,
                      fontWeight: FontWeight.bold,
                      color: Color(MyColors.darkGrey),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.3),
                  child: SizedBox(
                    // color: Colors.red,
                    width: w * 0.9,
                    height: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SetPositionPage(
                                          type: _pinType,
                                        )),
                              ),
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
                                  child: const Center(
                                    child: Text(
                                      'SAVE ON MAP',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(MyColors.lightBeige),
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
                                      color:
                                          _isToggleOn ? const Color(MyColors.orange) : const Color(MyColors.lightBeige),
                                      blurRadius: 4,
                                      spreadRadius: -0.1,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isToggleOn
                                      ? const Text(
                                          'RELEASE AND SAVE',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(MyColors.darkGrey),
                                          ),
                                        )
                                      : Text(
                                          _pins[_pinType.toString().split('.')[1]] != null
                                              ? DateFormat('yyyy.MM.dd HH:mm')
                                                  .format(_pins[_pinType.toString().split('.')[1]]!.position.timestamp)
                                              : '-',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(MyColors.darkGrey),
                                          ),
                                        ),
                                ),
                              ),
                            )
                          ],
                        ),
// current position save toggle
                        Container(
                          width: 70,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: _isToggleOn ? Color(MyColors.darkOrange) : Colors.black26,
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: _isToggleOn ? const Color(MyColors.orange) : const Color(MyColors.lightBeige),
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
                                        final String? saveType = await _setCurrentPosition();
                                        if (saveType != null) {
                                          final color = switch (_pinType) {
                                            PinType.green => const Color(MyColors.green),
                                            PinType.red => const Color(MyColors.red),
                                            PinType.blue => const Color(MyColors.blue)
                                          };
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              customSnackbar(
                                                '${saveType.toUpperCase()} に現在地を登録しました',
                                                color,
                                              ),
                                            );
                                          }
                                          setState(() {});
                                        }
                                      }
                                      _resetToggle();
                                    },
                                    onDragUpdate: (details) {
                                      _animationController.value = _dragPositionY / 110;
                                      print(_animationController.value);
                                      setState(() {
                                        _dragPositionY += details.delta.dy;
                                        if (_dragPositionY > 110) _dragPositionY = 110;
                                        if (_dragPositionY < 0) _dragPositionY = 0;
                                        if (_dragPositionY > 100) {
                                          _isToggleOn = true;
                                        } else {
                                          _isToggleOn = false;
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
                ),
                Align(
                  alignment: const Alignment(0, 0.95),
                  child: Container(
                    height: w * 0.4,
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
                        children: [
                          const Text(
                            'FIND',
                            style: TextStyle(
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
                                    final Pin? pin = _pins[_pinType.toString().split('.')[1]];
                                    if (pin == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        customSnackbar(
                                          '登録されていません',
                                          const Color(MyColors.red),
                                        ),
                                      );
                                      return;
                                    }
                                    if (mounted) {
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
                                    final Pin? pin = _pins[_pinType.toString().split('.')[1]];
                                    if (pin == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        customSnackbar(
                                          '登録されていません',
                                          const Color(MyColors.red),
                                        ),
                                      );
                                      return;
                                    } else if (cameras.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        customSnackbar(
                                          'カメラを認識できませんでした',
                                          const Color(MyColors.red),
                                        ),
                                      );
                                      return;
                                    }
                                    if (mounted) {
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
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          IgnorePointer(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/noise.png',
                width: w,
                height: h,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, 0.4),
            child: SizedBox(
              width: double.infinity,
              height: h / 3.5,
              child: PageView.builder(
                physics: const ClampingScrollPhysics(),
                controller: _pageController,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Align(
                    child: SizedBox(
                      width: 300,
                      height: 300 * _sizeRates[index],
                      child: Image.asset(
                        'assets/images/pin${index + 1}.png',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
