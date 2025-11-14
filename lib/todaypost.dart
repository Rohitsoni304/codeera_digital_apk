import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'File_uploadScreen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodayPostscreen extends StatefulWidget {
  String postimage;
  String id;
  String name;

  TodayPostscreen({
    super.key,
    required this.postimage,
    required this.id,
    required this.name,
  });

  @override
  State<TodayPostscreen> createState() => _TodayPostscreenState();
}

class _TodayPostscreenState extends State<TodayPostscreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  // Animation for BORDER
  late AnimationController borderController;
  late Animation<double> borderAnimation;

  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    // SCALE ANIMATION (Original Code)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // BORDER ANIMATION
    borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    borderAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: borderController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    borderController.dispose();
    super.dispose();
  }

  Future<void> _uploadToApi(String status) async {
    setState(() => _isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) return;

      var uri = Uri.parse('https://codeeratech.in/api/tasks/update');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['task_id'] = widget.id;
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
      var res = jsonDecode(body);

      if (response.statusCode == 200) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Upload error: $e");
    }

    setState(() => _isUploading = false);
  }

  void _openFeedbackScreen(BuildContext context) async {
    await _controller.forward();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VideoFeedbackScreen()),
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
                  widget.name.toString(),
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 25),

                // ⭐ ANIMATED GRADIENT BORDER ⭐
                Hero(
                  tag: "videoHero",
                  child: AnimatedBuilder(
                    animation: borderAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [Colors.black, Colors.white, Colors.black],
                            stops: [
                              (borderAnimation.value - 0.3).clamp(0.0, 1.0),
                              borderAnimation.value,
                              (borderAnimation.value + 0.3).clamp(0.0, 1.0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Container(
                          height: size.height * 0.55,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(widget.postimage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        onTap: () => _uploadToApi('5'),
                        child: _iconButton(FontAwesomeIcons.solidHeart)),

                    InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UploadScreen(taskid: widget.id.toString()),
                            ),
                          );
                        },
                        child: _iconButton(FontAwesomeIcons.penToSquare)),

                    _iconButton(FontAwesomeIcons.solidCommentDots,
                        onTap: () => _openFeedbackScreen(context)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

// ---------------- FEEDBACK SCREEN ---------------- //

class VideoFeedbackScreen extends StatelessWidget {
  const VideoFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Feedback Screen")),
    );
  }
}
