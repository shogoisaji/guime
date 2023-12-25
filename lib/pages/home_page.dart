import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guime/animations/title_animation.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/pages/camera_page.dart';
import 'package:guime/pages/map_page.dart';
import 'package:guime/services/shared_preferences_helper.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:guime/widgets/custom_snackbar.dart';
import 'package:guime/widgets/home_tile.dart';
import 'package:guime/widgets/custom_snackbar.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.cameras});
  final cameras;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _latitudeEditingController = TextEditingController();
  final TextEditingController _longitudeEditingController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.5, initialPage: 1);
  PinType _pinType = PinType.blue;
  double _centerLightOpacity = 1.0;

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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(MyColors.beige),
              // gradient: LinearGradient(
              //   begin: Alignment(-0.5, -0.3),
              //   end: Alignment(0.5, 0.3),
              //   colors: [
              //     Color(MyColors.darkBlue),
              //     Color(MyColors.darkDarkBlue),
              //   ],
              // ),
            ),
            child:
                // Center Circle Light
                Align(
                    alignment: const Alignment(0, -0.7),
                    child: Opacity(
                      opacity: _centerLightOpacity,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8,
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
          ),
          const Align(
            alignment: Alignment(0, -0.72),
            child: TitleAnimation(),
          ),
// 動くLOGOに変える予定！！

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      children: [
                        InkWell(
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('現在地登録'),
                              content: Column(
                                children: [
                                  TextField(
                                    controller: _latitudeEditingController,
                                    decoration: const InputDecoration(
                                      labelText: '緯度',
                                    ),
                                  ),
                                  TextField(
                                    controller: _longitudeEditingController,
                                    decoration: const InputDecoration(
                                      labelText: '経度',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('キャンセル'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final Pin pin = Pin(
                                      type: _pinType,
                                      position: Position(
                                        latitude: double.parse(_latitudeEditingController.text),
                                        longitude: double.parse(_longitudeEditingController.text),
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
                                    if (_latitudeEditingController.text.isEmpty ||
                                        _longitudeEditingController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('緯度と経度を入力してください'),
                                        ),
                                      );
                                      return;
                                    } else if (!RegExp(r'^-?([1-8]?[1-9]|[1-9]0)\.{1}\d{1,6}')
                                            .hasMatch(_latitudeEditingController.text) ||
                                        !RegExp(r'^-?([1-9]?[1-9]|[1-9]0|1[0-7][0-9]|180)\.{1}\d{1,6}')
                                            .hasMatch(_longitudeEditingController.text)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('入力値が正しくありません'),
                                        ),
                                      );
                                      return;
                                    }
                                    final saveType = await SharedPreferencesHelper().savePin(pin);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      customSnackbar('$saveTypeを登録しました', Color(MyColors.darkPurple)),
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: const Text('登録'),
                                ),
                              ],
                            ),
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
                                '(${value.position.latitude}, ${value.position.longitude}))',
                                Color(MyColors.darkBlue),
                              ),
                            );
                          },
                          child: HomeTile(
                            title: '情報',
                            icon: Icons.info,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
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
                          },
                          child: const HomeTile(
                            title: 'カメラで探す',
                            icon: Icons.camera_alt,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapPage(),
                            ),
                          ),
                          child: const HomeTile(
                            title: 'マップで探す',
                            icon: Icons.map,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Container(
                          color: PinType.values[index].color,
                          width: 250,
                          height: 250,
                          child: Center(child: Text(index.toString())),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
