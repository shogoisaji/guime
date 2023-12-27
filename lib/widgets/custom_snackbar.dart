import 'package:flutter/material.dart';
import 'package:guime/theme/color_theme.dart';

SnackBar customSnackbar(String message, Color color) {
  return SnackBar(
    backgroundColor: Colors.transparent,
    duration: const Duration(milliseconds: 1500),
    elevation: 0,
    content: Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(MyColors.lightBeige),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: color, width: 5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
                child: Text(message,
                    style:
                        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(MyColors.darkGrey)))),
          ),
        ],
      ),
    ),
  );
}
