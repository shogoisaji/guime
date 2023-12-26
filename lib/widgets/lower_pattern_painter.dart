import 'package:flutter/material.dart';

class LowerPatternPainter extends CustomPainter {
  final Color color;
  final double width;
  const LowerPatternPainter({required this.width, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final path1 = Path()..addOval(Rect.fromCircle(center: center, radius: width * 1.1));
    final path2 = Path()..addOval(Rect.fromCircle(center: center, radius: width * 1.1 + 8));

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
