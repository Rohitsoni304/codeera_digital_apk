// import 'package:flutter/material.dart';
// import 'ChatScreen.dart';
// import 'chat_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final userIdController = TextEditingController();
//   final peerIdController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Agora Chat Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: userIdController,
//               decoration: const InputDecoration(labelText: "Your User ID"),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: peerIdController,
//               decoration: const InputDecoration(labelText: "Peer User ID"),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ChatScreen(
//                       userId: userIdController.text.trim(),
//                       peerId: peerIdController.text.trim(),
//                     ),
//                   ),
//                 );
//               },
//               child: const Text("Start Chat"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
