import 'package:flutter/material.dart';
import 'Chatui.dart';

class ChatListUI extends StatelessWidget {
  const ChatListUI({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {'name': 'Rohit Sharma', 'lastMsg': 'Hey, how are you?'},
      {'name': 'Neha Verma', 'lastMsg': 'Please check the report.'},
      {'name': 'Marketing Team', 'lastMsg': 'Design updated 🎨'},
      {'name': 'Client Support', 'lastMsg': 'Sure, will do.'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Chats",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatUI(userName: chat['name']!),
                  ),
                );
              },
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                child: const Icon(Icons.person, color: Colors.blueAccent),
              ),
              title: Text(
                chat['name']!,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black),
              ),
              subtitle: Text(
                chat['lastMsg']!,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.black26),
            ),
          );
        },
      ),
    );
  }
}
