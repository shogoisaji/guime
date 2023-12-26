import 'dart:convert';

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
import 'package:guime/widgets/home_tile.dart';
import 'package:guime/widgets/custom_snackbar.dart';
import 'package:guime/widgets/lower_pattern_painter.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.cameras});
  final cameras;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _latitudeEditingController = TextEditingController();
  final TextEditingController _longitudeEditingController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.45, initialPage: 1);
  PinType _pinType = PinType.blue;
  double _centerLightOpacity = 1.0;
  List<double> _sizeRates = [0.1, 1.0, 0.5];

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

  @override
  initState() {
    super.initState();
    _pageController.addListener(_updateStateOnScroll);
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
    final double w = MediaQuery.of(context).size.width;
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
              alignment: const Alignment(0, -0.7),
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
            alignment: Alignment(0, -0.72),
            child: TitleAnimation(),
          ),
// 動くLOGOに変える予定！！

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    children: [
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SetPositionPage(
                                    type: _pinType,
                                  )),
                          //  showDialog(
                          //   context: context,
                          //   builder: (context) => AlertDialog(
                          //   title: const Text('現在地登録'),
                          //   content: Column(
                          //     children: [
                          //       TextField(
                          //         controller: _latitudeEditingController,
                          //         decoration: const InputDecoration(
                          //           labelText: '緯度',
                          //         ),
                          //       ),
                          //       TextField(
                          //         controller: _longitudeEditingController,
                          //         decoration: const InputDecoration(
                          //           labelText: '経度',
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          //   actions: [
                          //     TextButton(
                          //       onPressed: () => Navigator.pop(context),
                          //       child: const Text('キャンセル'),
                          //     ),
                          //     TextButton(
                          //       onPressed: () async {
                          //         final Pin pin = Pin(
                          //           type: _pinType,
                          //           position: Position(
                          //             latitude: double.parse(_latitudeEditingController.text),
                          //             longitude: double.parse(_longitudeEditingController.text),
                          //             timestamp: DateTime.now(),
                          //             accuracy: 0,
                          //             altitude: 0,
                          //             heading: 0,
                          //             speed: 0,
                          //             speedAccuracy: 0,
                          //             floor: null,
                          //             isMocked: false,
                          //             altitudeAccuracy: 0,
                          //             headingAccuracy: 0,
                          //           ),
                          //           description: '',
                          //           image: '',
                          //         );
                          //         if (_latitudeEditingController.text.isEmpty ||
                          //             _longitudeEditingController.text.isEmpty) {
                          //           ScaffoldMessenger.of(context).showSnackBar(
                          //             const SnackBar(
                          //               content: Text('緯度と経度を入力してください'),
                          //             ),
                          //           );
                          //           return;
                          //         } else if (!RegExp(r'^-?([1-8]?[1-9]|[1-9]0)\.{1}\d{1,6}')
                          //                 .hasMatch(_latitudeEditingController.text) ||
                          //             !RegExp(r'^-?([1-9]?[1-9]|[1-9]0|1[0-7][0-9]|180)\.{1}\d{1,6}')
                          //                 .hasMatch(_longitudeEditingController.text)) {
                          //           ScaffoldMessenger.of(context).showSnackBar(
                          //             const SnackBar(
                          //               content: Text('入力値が正しくありません'),
                          //             ),
                          //           );
                          //           return;
                          //         }
                          //         final saveType = await SharedPreferencesHelper().savePin(pin);
                          //         ScaffoldMessenger.of(context).showSnackBar(
                          //           customSnackbar('$saveTypeを登録しました', Color(MyColors.darkPurple)),
                          //         );
                          //         Navigator.pop(context);
                          //       },
                          //       child: const Text('登録'),
                          //     ),
                          //   ],
                          // ),
                        ),
                        child: HomeTile(
                          title: '現在地登録',
                          icon: Icons.pin_drop,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final value = await SharedPreferencesHelper().loadPin(_pinType);
                          if (value == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              customSnackbar(
                                '登録されていません',
                                Colors.grey,
                              ),
                            );
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            customSnackbar(
                              '(${value.position.latitude}, ${value.position.longitude}, ${DateFormat('yyyy.MM.dd HH:mm').format(value.position.timestamp)})',
                              Color(MyColors.darkBlue),
                            ),
                          );
                        },
                        child: HomeTile(
                          title: '情報',
                          icon: Icons.info,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                Container(
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
                      // color: Color(MyColors.lightBeige),
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
                          'Find',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(MyColors.darkGrey),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            customButton(
                                child: Icon(Icons.map, color: Color(MyColors.lightBeige), size: 48),
                                color: Color(MyColors.darkGrey),
                                onTapped: () async {
                                  final Pin? pin = await SharedPreferencesHelper().loadPin(_pinType);
                                  if (pin == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      customSnackbar(
                                        '登録されていません',
                                        Colors.grey,
                                      ),
                                    );
                                    return;
                                  } else if (widget.cameras.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      customSnackbar(
                                        'カメラを認識できませんでした',
                                        Colors.grey,
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
                                  final Pin? pin = await SharedPreferencesHelper().loadPin(_pinType);
                                  if (pin == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      customSnackbar(
                                        '登録されていません',
                                        Colors.grey,
                                      ),
                                    );
                                    return;
                                  }
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CameraPage(
                                          cameras: widget.cameras,
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
                // Center Circle Light
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, 0.4),
            child: Container(
              width: double.infinity,
              height: h / 3.5,
              child: PageView.builder(
                physics: const ClampingScrollPhysics(),
                controller: _pageController,
                itemCount: 3,
                itemBuilder: (context, index) {
                  print('${_sizeRates[0]},${_sizeRates[1]},${_sizeRates[2]}');
                  return Align(
                    child: Container(
                      // color: Colors.orange[200 * (index + 1)],
                      width: 300,
                      height: 300 * _sizeRates[index],
                      child: Image.asset(
                        'assets/images/pin${index + 1}.png',
                        // width: 200,
                        // height: 800,
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
