import 'package:flutter/material.dart';

Widget customButton({
  required Widget child,
  required VoidCallback onTapped,
  required double width,
  Color? color,
}) {
  return InkWell(
    onTap: onTapped,
    child: Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
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
        width: width,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              spreadRadius: -0.1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}
