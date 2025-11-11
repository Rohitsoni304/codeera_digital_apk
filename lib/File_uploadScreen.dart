import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  final int _maxFiles = 5;
  bool _isUploading = false;

  /// Pick up to 5 images/videos
  Future<void> _pickFiles() async {
    print("startapi");
    if (_selectedFiles.length >= _maxFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can select up to 5 files only")),
      );
      return;
    }

    final List<XFile> files = await _picker.pickMultipleMedia();
    if (files.isNotEmpty) {
      setState(() {
        int remainingSlots = _maxFiles - _selectedFiles.length;
        _selectedFiles.addAll(files.take(remainingSlots));
      });
    }
  }

  /// Upload files and review to API
  Future<void> _uploadToApi() async {
    print("startupload");
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one file.")),
      );
      return;
    }

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

      // Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Fields
      request.fields['task_id'] = "6"; // static for now
      request.fields['status'] = "3";
      request.fields['client_review'] =
      _textController.text.isNotEmpty ? _textController.text : "No review";

      // Attach files
      for (var file in _selectedFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          'client_attached_files[]',
          file.path,
        ));
      }

      // Send API request
      var response = await request.send();
      var resBody = await response.stream.bytesToString();
      final resJson = jsonDecode(resBody);

      if (response.statusCode == 200) {
        String message = resJson['message'] ?? "Upload successful ✅";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        setState(() {
          _selectedFiles.clear();
          _textController.clear();
        });
      } else {
        String message = resJson['message'] ?? "Upload failed ❌";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print("⚠️ Error uploading: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text(
          "Update Your Changes",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// Card Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Write a Caption",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _textController,
                          maxLines: 4,
                          maxLength: 200,
                          decoration: InputDecoration(
                            hintText: "Share your thoughts or description...",
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        /// Selected Files Preview
                        if (_selectedFiles.isNotEmpty) ...[
                          const Text(
                            "Selected Files:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedFiles.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final file = _selectedFiles[index];
                                final isVideo = file.path.endsWith(".mp4") ||
                                    file.path.endsWith(".mov") ||
                                    file.path.endsWith(".avi");

                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: isVideo
                                          ? Container(
                                        width: 100,
                                        color: Colors.black26,
                                        child: const Icon(
                                          Icons.videocam,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      )
                                          : Image.file(
                                        File(file.path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() =>
                                              _selectedFiles.removeAt(index));
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),

                        /// Choose Files Button
                        Center(
                          child: InkWell(
                            onTap: _pickFiles,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.blueAccent, Colors.lightBlue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file_rounded,
                                      color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    "Choose Files",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        /// Submit Button
                        InkWell(
                          onTap: _uploadToApi,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _isUploading
                                ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                                : const Center(
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
