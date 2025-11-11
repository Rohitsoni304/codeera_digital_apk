import 'package:flutter/material.dart';

class ChatUI extends StatefulWidget {
  final String userName;
  const ChatUI({super.key, required this.userName});

  @override
  State<ChatUI> createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> demoMessages = [
    {'text': 'Hey there!', 'isMe': false},
    {'text': 'Hi 👋 How are you?', 'isMe': true},
    {'text': 'All good! Working on campaign design.', 'isMe': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.blueAccent),
            ),
            const SizedBox(width: 10),
            Text(
              widget.userName,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: demoMessages.length,
              itemBuilder: (context, index) {
                final msg = demoMessages[index];
                return Align(
                  alignment: msg['isMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg['isMe']
                          ? Colors.blueAccent
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: msg['isMe'] ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: const TextStyle(color: Colors.black54),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
