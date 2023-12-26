import 'package:flutter/material.dart';
import 'package:guime/theme/color_theme.dart';

SnackBar customSnackbar(String message, Color color) {
  return SnackBar(
    content: Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
          child: Text(message,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(MyColors.darkGrey)))),
    ),
    backgroundColor: color,
    duration: const Duration(seconds: 1),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(50),
      topRight: Radius.circular(50),
    )),
    elevation: 5,
  );
}
