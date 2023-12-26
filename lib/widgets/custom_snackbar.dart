import 'package:flutter/material.dart';

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
            offset: const Offset(-3, -3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Center(
          child:
              Text(message, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87))),
    ),
    backgroundColor: Colors.red[400],
    duration: const Duration(seconds: 1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    elevation: 5,
  );
}
