import 'package:flutter/material.dart';
import 'package:guime/models/pin_model.dart';
import 'package:guime/theme/color_theme.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatefulWidget {
  final Pin pin;
  const LoadingWidget({super.key, required this.pin});

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
    final pinIndex = PinType.values.indexOf(widget.pin.type);
    return Container(
        color: const Color(MyColors.beige),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0.0, -0.5),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0.0, _animation.value * 30),
                    child: Image.asset('assets/images/pin${pinIndex + 1}.png', width: 100, fit: BoxFit.fitWidth),
                  );
                },
              ),
            ),
            Image.asset('assets/images/noise.png', width: double.infinity, height: double.infinity, fit: BoxFit.fill),
            Align(
              alignment: const Alignment(0.0, 0.2),
              child: Lottie.asset('assets/lottie/loading.json', width: 200),
            ),
          ],
        ));
  }
}
