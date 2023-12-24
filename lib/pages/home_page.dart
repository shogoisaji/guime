import 'package:flutter/material.dart';
import 'package:guime/animations/title_animation.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/pages/camera_page.dart';
import 'package:guime/pages/map_page.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:guime/widgets/home_tile.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.cameras});
  final cameras;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.5, -0.3),
                end: Alignment(0.5, 0.3),
                colors: [
                  Color(MyColors.darkBlue),
                  Color(MyColors.darkDarkBlue),
                ],
              ),
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
                          onTap: () => print('現在地登録'),
                          child: HomeTile(
                            title: '現在地登録',
                            icon: Icons.pin_drop,
                          ),
                        ),
                        InkWell(
                          onTap: () => print('情報'),
                          child: HomeTile(
                            title: '情報',
                            icon: Icons.info,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CameraPage(cameras: widget.cameras),
                            ),
                          ),
                          child: HomeTile(
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
                          child: HomeTile(
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
