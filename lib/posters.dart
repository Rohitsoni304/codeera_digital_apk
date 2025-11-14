import 'dart:convert';
import 'package:codeera_digital_apk/todaypost.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'File_uploadScreen.dart';

class posterGalleryScreen extends StatefulWidget {
  const posterGalleryScreen({super.key});

  @override
  State<posterGalleryScreen> createState() => _posterGalleryScreenState();
}

class _posterGalleryScreenState extends State<posterGalleryScreen> {
  Future<void> getdasta() async {
    print('startapi');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      setState(() {
        errorMessage = "Authentication token missing";
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("https://codeeratech.in/api/user/tasks?type=post"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200) {
        List<dynamic> allTasks = data['tasks'] ?? [];

        // ✅ Get today's date in "yyyy-MM-dd" format
        final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

        // ✅ Filter tasks where created_at matches today's date
        final filteredTasks = allTasks.where((task) {
          final createdAt = task['created_at'] ?? '';
          if (createdAt.isEmpty) return false;
          // Extract only the date portion (yyyy-MM-dd)
          final createdDate = createdAt.split(' ')[0];
          return createdDate == today;
        }).toList();

        setState(() {
          tasks = filteredTasks;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${filteredTasks.length} tasks for today'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          errorMessage = data["message"] ?? "Failed to load data";
          isLoading = false;
        });
        _showError(data["message"] ?? "Something went wrong");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error: $e";
        isLoading = false;
      });
      _showError("Network error: $e");
    }
  }


  List<dynamic> tasks = [];
  bool isLoading = true;
  String? errorMessage;

  final String baseUrl = "https://codeeratech.in//uploads/tasks/";

  Future<void> getdata() async {
    print('startapi');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      setState(() {
        errorMessage = "Authentication token missing";
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("https://codeeratech.in/api/user/tasks?type=post"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200) {
        setState(() {
          tasks = data['tasks'] ?? [];
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${tasks.length} posts'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          errorMessage = data["message"] ?? "Failed to load data";
          isLoading = false;
        });
        _showError(data["message"] ?? "Something went wrong");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error: $e";
        isLoading = false;
      });
      _showError("Network error: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return "Pending";
      case 5:
        return "Completed";
      default:
        return "Unknown";
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange.shade600;
      case 5:
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              const Center(
                child: Text(
                  "Posts",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Loading / Error / Data
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ?
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 60, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, color: Colors.red.shade700),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          getdata();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
                    : tasks.isEmpty
                    ? const Center(
                  child: Text(
                    "No posts available",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
                    :
                GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.51,
                  ),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final imageUrl = task['file_path'] != null
                        ? baseUrl + task['file_path']
                        : null;

                    return _posterCard(
                      imageUrl: imageUrl,
                      title: task['title'] ?? "Untitled",
                      status: task['status'] ?? 0,
                      id: task['id']??0
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget  _posterCard({
    required String? imageUrl,
    required String title,
    required int status,
    required int id,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TodayPostscreen(postimage: imageUrl.toString(),id: id.toString(),name:title ,),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1,
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade200, Colors.grey.shade300],
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(Icons.broken_image,
                          color: Colors.grey.shade500, size: 32),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image,
                      color: Colors.grey.shade400, size: 32),
                ),
              ),
            ),

            SizedBox(height: 10),

            // TITLE
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.2,
              ),
            ),

            SizedBox(height: 8),

            // STATUS BUTTON
            if (status == 0)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadScreen(taskid: id.toString()),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      "Update Status",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 10),

            // STATUS TAG
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getStatusText(status),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}