import 'package:flutter/material.dart';
import 'package:guime/theme/color_theme.dart';

Widget customBackButton() {
  return InkWell(
    child: Container(
      decoration: BoxDecoration(
        color: const Color(MyColors.darkBlue),
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
      padding: const EdgeInsets.all(2),
      child: Container(
        width: 60,
        padding: const EdgeInsets.all(5),
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
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 36),
      ),
    ),
  );
}
