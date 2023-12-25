import 'package:flutter/material.dart';

SnackBar customSnackbar(String message, Color color) {
  return SnackBar(
    content: Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Center(
          child:
              Text(message, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87))),
    ),
    backgroundColor: Colors.transparent,
    duration: Duration(seconds: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
    elevation: 10,
    clipBehavior: Clip.none,
  );
}
