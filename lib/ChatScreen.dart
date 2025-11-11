// import 'package:flutter/material.dart';
//
// import 'agora.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String userId;
//   final String peerId;
//
//   const ChatScreen({required this.userId, required this.peerId, Key? key})
//       : super(key: key);
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [];
//   final AgoraRtmService _agora = AgoraRtmService();
//
//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }
//
//   Future<void> _initAgora() async {
//     await _agora.init(widget.userId);
//     await _agora.createChannel("chat_${widget.userId}_${widget.peerId}",
//             (msg, memberId) {
//           setState(() {
//             _messages.add({
//               "text": msg?.text,
//               "sender": memberId,
//               "isMe": memberId == widget.userId,
//             });
//           });
//         });
//   }
//
//   void _sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;
//
//     setState(() {
//       _messages.add({"text": text, "sender": widget.userId, "isMe": true});
//     });
//
//     _controller.clear();
//     await _agora.sendPeerMessage(widget.peerId, text);
//   }
//
//   @override
//   void dispose() {
//     _agora.leaveChannel();
//     _agora.logout();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat with ${widget.peerId}"),
//         backgroundColor: Colors.black87,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final msg = _messages[index];
//                 return Align(
//                   alignment: msg["isMe"]
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 5),
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: msg["isMe"]
//                           ? Colors.blueAccent.shade100
//                           : Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Text(
//                       msg["text"],
//                       style: TextStyle(
//                         color: msg["isMe"] ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           SafeArea(
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: "Type message...",
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.all(14),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.blue),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
