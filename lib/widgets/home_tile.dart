// import 'package:flutter/material.dart';
// import 'dart:ui' as ui;

// class HomeTile extends StatefulWidget {
//   final String title;
//   final IconData icon;
//   const HomeTile({super.key, required this.title, required this.icon});

//   @override
//   State<HomeTile> createState() => _HomeTileState();
// }

// class _HomeTileState extends State<HomeTile> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: BackdropFilter(
//           filter: ui.ImageFilter.blur(
//             sigmaX: 5.0,
//             sigmaY: 5.0,
//           ),
//           child: Container(
//             color: Colors.grey.withOpacity(0.3),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   widget.icon,
//                   size: 100,
//                   color: Colors.white,
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   widget.title,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// // class HomeTile extends StatefulWidget {
// //   final String title;
// //   final IconData icon;
// //   const HomeTile({super.key, required this.title, required this.icon});

// //   @override
// //   State<HomeTile> createState() => _HomeTileState();
// // }

// // class _HomeTileState extends State<HomeTile> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       margin: const EdgeInsets.all(10),
// //       decoration: BoxDecoration(
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.2),
// //             blurRadius: 1,
// //             offset: const Offset(0, 0),
// //           ),
// //         ],
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [
// //             Colors.white.withOpacity(0.2),
// //             Colors.transparent,
// //           ],
// //         ),
// //         borderRadius: BorderRadius.circular(10),
// //       ),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             widget.icon,
// //             size: 100,
// //             color: Colors.white,
// //           ),
// //           const SizedBox(height: 10),
// //           Text(
// //             widget.title,
// //             style: TextStyle(
// //               fontSize: 20,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.white,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
