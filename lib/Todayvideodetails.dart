import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'File_uploadScreen.dart';

class VideoDetails extends StatefulWidget {
  final String postvideo;
  final String id;
  final String name;

  const VideoDetails({
    super.key,
    required this.postvideo,
    required this.id,
    required this.name,
  });

  @override
  State<VideoDetails> createState() => _VideoDetailsState();
}

class _VideoDetailsState extends State<VideoDetails> {
  // Video controller
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool isVideoReady = false;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  bool _isUploading = false;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.network(widget.postvideo)
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: false,
          looping: false,
        );
        setState(() => isVideoReady = true);
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  // Pick images
  Future<void> _pickAttachments() async {
    try {
      setState(() => _isPicking = true);
      final files = await _picker.pickMultiImage();
      if (files != null) {
        _selectedFiles.clear();
        _selectedFiles.addAll(files);
      }
    } finally {
      setState(() => _isPicking = false);
    }
  }

  // Upload API
  Future<void> _uploadToApi(String status) async {
    setState(() => _isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("authToken");
      if (token == null) return;

      var request =
      http.MultipartRequest("POST", Uri.parse("https://codeeratech.in/api/tasks/update"));

      request.headers["Authorization"] = "Bearer $token";
      request.fields["task_id"] = widget.id;
      request.fields["status"] = status;
      request.fields["client_review"] =
      status == "5" ? "Approved" : "Need Changes";

      for (var file in _selectedFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          "client_attached_files[]",
          file.path,
        ));
      }

      var response = await request.send();
      var resString = await response.stream.bytesToString();
      var data = jsonDecode(resString);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data["message"])));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Upload Failed")));
      }
    } catch (e) {
      debugPrint("Upload error: $e");
    }

    setState(() => _isUploading = false);
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VideoFeedbackScreen()),
    );
  }

  void _openNeedChanges() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadScreen(taskid: widget.id),
      ),
    );
  }

  Widget _actionButton({
    required List<Color> gradient,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 96,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradient.last.withOpacity(0.3),
                  blurRadius: 8,
                )
              ],
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 25),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600))
        ],
      ),
    );
  }

  // Attachments preview
  Widget _attachmentPreview() {
    if (_selectedFiles.isEmpty) {
      return TextButton.icon(
        onPressed: _pickAttachments,
        icon: const Icon(Icons.attach_file),
        label: const Text("Add Attachments"),
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        itemBuilder: (_, i) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(_selectedFiles[i].path),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading:
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
      ),

      body: Stack(
        children: [
          // TOP video area
          SizedBox(
            height: size.height * 0.80,
            width: size.width,
            child: Hero(
              tag: "video_${widget.id}",
              child: isVideoReady
                  ? Chewie(controller: _chewieController!)
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          Positioned(
            top: size.height * 0.50,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.55),
                    Colors.black,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Bottom Split Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.13,
            maxChildSize: 0.33,
            builder: (_, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.zero,
                  children: [
                    // Divider
                    Center(
                      child: Container(
                        width: 45,
                        height: 05,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      widget.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(
                          gradient: const [
                            Color(0xFF0BAB64),
                            Color(0xFF3BB78F)
                          ],
                          icon: FontAwesomeIcons.check,
                          label: "Approve",
                          onTap: () => _uploadToApi("5"),
                        ),
                        _actionButton(
                          gradient: const [
                            Color(0xFFFF8A00),
                            Color(0xFFFF5F00)
                          ],
                          icon: FontAwesomeIcons.penToSquare,
                          label: "Need Changes",
                          onTap: _openNeedChanges,
                        ),
                        _actionButton(
                          gradient: const [
                            Color(0xFF3E8BFF),
                            Color(0xFF6A5AE0)
                          ],
                          icon: FontAwesomeIcons.solidCommentDots,
                          label: "Chat",
                          onTap: _openChat,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ----------------- FEEDBACK SCREEN -----------------
class VideoFeedbackScreen extends StatelessWidget {
  const VideoFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Chat / Feedback screen")),
    );
  }
}
