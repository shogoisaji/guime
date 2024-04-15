import 'package:flutter/material.dart';

class LowerPatternPainter extends CustomPainter {
  final Color color;
  final double width;
  final double positionY;
  const LowerPatternPainter({required this.width, required this.color, required this.positionY});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2 + positionY);
    final radius = width * 1.1;
    final shadowRadius = radius + 8;

    // 描画領域を canvas のサイズ内に制限

    final path1 = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    final path2 = Path()..addOval(Rect.fromCircle(center: center, radius: shadowRadius));

    // 影を描画
    canvas.drawShadow(path2, Colors.black.withOpacity(0.4), 7.0, false);

    // 円を描画
    canvas.drawPath(path1, paint);
  }

  @override
  bool shouldRepaint(LowerPatternPainter old) {
    return false;
  }
}
