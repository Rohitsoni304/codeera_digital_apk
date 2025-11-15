// today_post_split_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'File_uploadScreen.dart';

class TodayPostscreen extends StatefulWidget {
  final String postimage;
  final String id;
  final String name;

  const TodayPostscreen({
    super.key,
    required this.postimage,
    required this.id,
    required this.name,
  });

  @override
  State<TodayPostscreen> createState() => _TodayPostscreenState();
}

class _TodayPostscreenState extends State<TodayPostscreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  bool _isUploading = false;
  bool _isPicking = false;

  // Pick multiple images (attachments)
  Future<void> _pickAttachments() async {
    try {
      setState(() => _isPicking = true);
      final List<XFile>? images = await _picker.pickMultiImage(imageQuality: 85);
      if (images != null && images.isNotEmpty) {
        _selectedFiles.clear();
        _selectedFiles.addAll(images);
      }
    } catch (e) {
      debugPrint("Picker error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick images: $e")),
      );
    } finally {
      setState(() => _isPicking = false);
    }
  }

  // Upload to same API as you had earlier
  Future<void> _uploadToApi(String status) async {
    setState(() => _isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Auth token missing — please login again.")),
        );
        setState(() => _isUploading = false);
        return;
      }

      var uri = Uri.parse('https://codeeratech.in/api/tasks/update');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['task_id'] = widget.id;
      request.fields['status'] = status;
      request.fields['client_review'] = status == '5' ? "Approved" : "Needs changes";

      // Attach selected files if any
      for (var file in _selectedFiles) {
        // Use file.path; image_picker returns XFile
        request.files.add(await http.MultipartFile.fromPath(
          'client_attached_files[]',
          file.path,
        ));
      }

      final streamResponse = await request.send();
      final bodyString = await streamResponse.stream.bytesToString();
      // try to decode safely
      dynamic data;
      try {
        data = jsonDecode(bodyString);
      } catch (_) {
        data = {'message': bodyString};
      }

      if (streamResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data?['message'] ?? 'Uploaded successfully')),
        );
        Navigator.pop(context); // close screen after success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data?['message'] ?? 'Upload failed')),
        );
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // Open feedback/chat screen (simple placeholder navigation)
  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ModernFeedbackScreen()),
    );
  }

  // Navigate to UploadScreen (keep your existing behavior)
  void _openNeedChanges() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadScreen(taskid: widget.id.toString()),
      ),
    );
  }

  // Small helper to build gradient buttons
  Widget _actionButton({
    required List<Color> gradient,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double width = 100,
    double height = 55,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradient.last.withOpacity(0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: width,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  // Attachment preview thumbnails
  Widget _attachmentPreview() {
    if (_isPicking) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_selectedFiles.isEmpty) {
      return TextButton.icon(
        onPressed: _pickAttachments,
        icon: const Icon(Icons.attach_file),
        label: const Text("Attach files (optional)"),
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final file = _selectedFiles[i];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(file.path),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedFiles.removeAt(i);
                    });
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // allow background image to go under status bar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top: full image (60% height). Use NetworkImage from API input.
          SizedBox(
            height: size.height * 0.90,
            width: size.width,
            child: Hero(
              tag: "post_image_${widget.id}",
              child: Image.network(
                widget.postimage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          ),

          // Slight gradient from image -> bottom for readability
          Positioned(
            top: size.height * 0.45,
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

          // Bottom: Draggable split sheet containing description + attachments + buttons
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.15,
            maxChildSize: 0.33,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // draggable indicator
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Title / description (from widget.name)
                      Text(
                        widget.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description area — you can supply more text from API if you have
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          // keep using name if no description available
                          "Description: ${widget.name}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // action buttons (three)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Approve — green gradient
                          _actionButton(
                            gradient: const [Color(0xFF0BAB64), Color(0xFF3BB78F)],
                            icon: FontAwesomeIcons.check,
                            label: "Approve",
                            onTap: () async {
                              if (_isUploading) return;
                              await _uploadToApi('5');
                            },
                          ),

                          // Need Changes — orange gradient
                          _actionButton(
                            gradient: const [Color(0xFFFF8A00), Color(0xFFFF5F00)],
                            icon: FontAwesomeIcons.penToSquare,
                            label: "Need Changes",
                            onTap: _openNeedChanges,
                          ),

                          // Chat — blue gradient
                          _actionButton(
                            gradient: const [Color(0xFF3E8BFF), Color(0xFF6A5AE0)],
                            icon: FontAwesomeIcons.solidCommentDots,
                            label: "Chat",
                            onTap: _openChat,
                          ),
                        ],
                      ),



                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

//   // helper to build one of the three big buttons (reused)
//   Widget _actionButton({
//     required List<Color> gradient,
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Column(
//         children: [
//           Container(
//             width: 96,
//             height: 56,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(colors: gradient),
//               borderRadius: BorderRadius.circular(14),
//               boxShadow: [
//                 BoxShadow(
//                   color: gradient.last.withOpacity(0.28),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 )
//               ],
//             ),
//             child: Center(child: Icon(icon, color: Colors.white)),
//           ),
//           const SizedBox(height: 6),
//           SizedBox(
//             width: 96,
//             child: Text(
//               label,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 12),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
}
// Simple placeholder chat/feedback screen
class ModernFeedbackScreen extends StatelessWidget {
  const ModernFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: Center(child: Text("Chat / Feedback screen (implement as needed)")),
    );
  }
}
