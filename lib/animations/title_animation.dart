import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:lottie/lottie.dart';

class TitleAnimation extends StatefulWidget {
  final double width;
  const TitleAnimation({super.key, required this.width});

  @override
  State<TitleAnimation> createState() => _TitleAnimationState();
}

class _TitleAnimationState extends State<TitleAnimation> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _lottieAnimation;

  @override
  void initState() {
    super.initState();
    _lottieAnimation = AnimationController(vsync: this, value: 0.5, duration: const Duration(seconds: 7))..repeat();
    _animationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..forward().then((value) {
        _animationController.reverse();
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _lottieAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animationController.value * math.pi / 2,
              child: Lottie.asset('assets/lottie/guime_title.json',
                  width: widget.width, height: widget.width, addRepaintBoundary: true),
            );
          },
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animationController.value * math.pi / 2 + 1,
              child: Lottie.asset('assets/lottie/guime_title.json',
                  controller: _lottieAnimation, width: widget.width, height: widget.width, addRepaintBoundary: true),
            );
          },
        ),
      ],
    );
  }
}
