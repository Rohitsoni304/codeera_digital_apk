import 'package:flutter/material.dart';
class VideoFeedbackScreen extends StatelessWidget {
  const VideoFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back + Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Feedback",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 🎬 Hero Transition Video
            Center(
              child: Hero(
                tag: "videoHero",
                child: Container(
                  height: size.height * 0.22,
                  width: size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/video_placeholder.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Video Info
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Promotional Video",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 3),
                  Text("Today, 9:00 AM",
                      style: TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: const Text("Ask for changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Chat
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Chat",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _ChatBubble(text: "The font size should be larger.", isMe: false),
                  _ChatBubble(text: "Increase the transition speed.", isMe: false),
                  _ChatBubble(text: "Sure, I will make these changes.", isMe: true),
                ],
              ),
            ),

            // Message bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Message",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                          BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueAccent,
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Chat Bubble ---------------- //
class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _ChatBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 14.5,
          ),
        ),
      ),
    );
  }
}