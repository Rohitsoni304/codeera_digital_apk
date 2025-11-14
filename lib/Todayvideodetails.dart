import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'File_uploadScreen.dart';

class VideoDetails extends StatefulWidget {
  String postvideo;
  String id;
  String name;

  VideoDetails({
    super.key,
    required this.postvideo,
    required this.id,
    required this.name,
  });

  @override
  State<VideoDetails> createState() => _VideoDetailsState();
}

class _VideoDetailsState extends State<VideoDetails>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  bool _isUploading = false;

  // ------------------ VIDEO PLAYER ------------------
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool isVideoReady = false;

  @override
  void initState() {
    super.initState();

    // Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Video Controller Initialization
    _videoController = VideoPlayerController.network(widget.postvideo)
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: false,
          looping: false,
          aspectRatio: _videoController.value.aspectRatio,
        );

        setState(() {
          isVideoReady = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _uploadToApi(String status) async {
    setState(() => _isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No auth token found! Please login again.")),
        );
        setState(() => _isUploading = false);
        return;
      }

      var uri = Uri.parse('https://codeeratech.in/api/tasks/update');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['task_id'] = widget.id.toString();
      request.fields['status'] = status;
      request.fields['client_review'] = "Approved";

      for (var file in _selectedFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          'client_attached_files[]',
          file.path,
        ));
      }

      var response = await request.send();
      var body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Success")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed")),
        );
      }
    } catch (e) {
      print(e);
    }

    setState(() => _isUploading = false);
  }

  void _openFeedbackScreen(BuildContext context) async {
    await _controller.forward();
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const VideoFeedbackScreen(),
        ),
      ),
    );
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),

                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // ------------------ VIDEO PLAYER INSIDE HERO ------------------
                Hero(
                  tag: "videoHero",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: size.height * 0.55,
                      width: 300,
                      color: Colors.black,
                      child: isVideoReady
                          ? Chewie(controller: _chewieController!)
                          : const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        onTap: () => _uploadToApi('5'),
                        child: _iconButton(FontAwesomeIcons.check,'Approve')),
                    InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadScreen(
                                taskid: widget.id.toString(),
                              ),
                            ),
                          );
                        },
                        child: _iconButton(FontAwesomeIcons.penToSquare,'Need Changes')),
                    _iconButton(FontAwesomeIcons.solidCommentDots,
                        onTap: () => _openFeedbackScreen(context),'Chat'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon,String text,{VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child:  Icon(icon, color: Colors.white, size: 26),
          ),
          Text(text,style: TextStyle(color: Colors.black,fontSize: 16),)
        ],
      ),
    );
  }
}

// ------------------------ FEEDBACK SCREEN ------------------------

class VideoFeedbackScreen extends StatelessWidget {
  const VideoFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new)),
                Text("Feedback",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),

            Hero(
              tag: "videoHero",
              child: Container(
                height: size.height * 0.22,
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black26,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _ChatBubble(text: "The font size should be larger.", isMe: false),
                  _ChatBubble(text: "Increase the transition speed.", isMe: false),
                  _ChatBubble(text: "Sure, I will make these changes.", isMe: true),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------------ CHAT BUBBLE ------------------------

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _ChatBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
