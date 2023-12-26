import 'package:flutter/material.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatefulWidget {
  final PinType type;
  final bool isAttention;
  final bool isCalibration;
  const LoadingWidget({super.key, required this.type, required this.isAttention, required this.isCalibration});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInQuart);
    _controller
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width > 500 ? 500 : MediaQuery.of(context).size.width;
    final pinIndex = PinType.values.indexOf(widget.type);
    return Container(
        color: const Color(MyColors.beige),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0.0, _animation.value * 30),
                        child: Image.asset('assets/images/pin${pinIndex + 1}.png', width: 100, fit: BoxFit.fitWidth),
                      );
                    },
                  ),
                  widget.isCalibration
                      ? Image.asset('assets/images/calibration.png', width: w * 0.6, fit: BoxFit.fitWidth)
                      : Container(),
                  widget.isAttention
                      ? Image.asset('assets/images/attention.png', width: w * 0.6, fit: BoxFit.fitWidth)
                      : Container(),
                  Lottie.asset('assets/lottie/loading.json', width: w / 2),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
            Image.asset('assets/images/noise.png', width: double.infinity, height: double.infinity, fit: BoxFit.fill),
          ],
        ));
  }
}
