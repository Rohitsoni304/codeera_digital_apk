// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'File_uploadScreen.dart';
//
// class TodayVideosScreen extends StatefulWidget {
//   const TodayVideosScreen({super.key});
//
//   @override
//   State<TodayVideosScreen> createState() => _TodayVideosScreenState();
// }
//
// class _TodayVideosScreenState extends State<TodayVideosScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//
//     _scaleAnimation = Tween<double>(begin: 1, end: 0.90).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   void _openFeedbackScreen(BuildContext context) async {
//     await _controller.forward();
//
//     await Navigator.push(
//       context,
//       PageRouteBuilder(
//         transitionDuration: const Duration(milliseconds: 600),
//         reverseTransitionDuration: const Duration(milliseconds: 400),
//         pageBuilder: (_, animation, __) => FadeTransition(
//           opacity: animation,
//           child: const VideoFeedbackScreen(),
//         ),
//       ),
//     );
//
//     _controller.reverse();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       body: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _scaleAnimation.value,
//             child: child,
//           );
//         },
//         child: SafeArea(
//           child: Column(
//             children: [
//               const SizedBox(height: 15),
//
//               // 🔥 Title with better font
//               const Text(
//                 "Today's Video",
//                 style: TextStyle(
//                   fontSize: 34,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.black87,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // 🔥 Premium Video Player UI
//               Hero(
//                 tag: "videoHero",
//                 child: Container(
//                   height: size.height * 0.63,
//                   width: size.width * 0.90,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(28),
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.black.withOpacity(0.2),
//                         Colors.black.withOpacity(0.05),
//                       ],
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.18),
//                         blurRadius: 20,
//                         spreadRadius: 2,
//                         offset: const Offset(0, 10),
//                       )
//                     ],
//                     image: const DecorationImage(
//                       image: AssetImage("assets/images/video_placeholder.jpg"),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   child: Center(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.white.withOpacity(0.8),
//                             Colors.white.withOpacity(0.1)
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                       ),
//                       padding: const EdgeInsets.all(6),
//                       child: const Icon(
//                         Icons.play_circle_fill_rounded,
//                         color: Colors.white,
//                         size: 105,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               // 🔥 Bottom Modern Action Buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _glassButton(FontAwesomeIcons.solidHeart),
//                   _glassButton(FontAwesomeIcons.penToSquare, onTap: () {}),
//                   _glassButton(FontAwesomeIcons.solidCommentDots,
//                       onTap: () => _openFeedbackScreen(context)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ⭐ New Modern Glass Button Style ⭐
//   Widget _glassButton(IconData icon, {VoidCallback? onTap}) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         width: 90,
//         height: 63,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           gradient: LinearGradient(
//             colors: [
//               Colors.white.withOpacity(0.25),
//               Colors.white.withOpacity(0.05),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.2),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blueAccent.withOpacity(0.20),
//               blurRadius: 12,
//               spreadRadius: 1,
//               offset: const Offset(0, 6),
//             ),
//           ],
//           // backdropFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
//         ),
//         child: Icon(icon, color: Colors.black87, size: 28),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
//
// // ---------------------------------------------------------
// // ---------------- FEEDBACK SCREEN (UNCHANGED) ------------
// // ---------------------------------------------------------
//
// class VideoFeedbackScreen extends StatelessWidget {
//   const VideoFeedbackScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Back & Title
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(Icons.arrow_back_ios_new, size: 20),
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     "Feedback",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             Hero(
//               tag: "videoHero",
//               child: Center(
//                 child: Container(
//                   height: size.height * 0.22,
//                   width: size.width * 0.9,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     image: const DecorationImage(
//                       image: AssetImage("assets/images/video_placeholder.jpg"),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 15),
//
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Promotional Video",
//                       style:
//                       TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                   SizedBox(height: 3),
//                   Text("Today, 9:00 AM",
//                       style: TextStyle(color: Colors.black54, fontSize: 13)),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 15),
//
//             Expanded(
//               child: Container(), // (kept unchanged as requested)
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
