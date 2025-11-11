import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodayVideosGalleryScreen extends StatefulWidget {
  const TodayVideosGalleryScreen({super.key});

  @override
  State<TodayVideosGalleryScreen> createState() => _TodayVideosGalleryScreenState();
}

class _TodayVideosGalleryScreenState extends State<TodayVideosGalleryScreen> {
  Future<void> getdata() async {
    print('startapi');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken'); // 👈 token saved earlier



    try {
      final response = await http.get(
        Uri.parse("https://codeeratech.in/api/user/tasks?type=video"),
        headers: {"Content-Type": "application/json",
          "Authorization": "Bearer $token",},

      );

      final data = jsonDecode(response.body);
      print(data);


      if (response.statusCode == 200) {
        setState(() {

        });
        // ✅ Show message clearly with number
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'ok'
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Something went wrong ❌"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  int _selectedIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }
  @override
  Widget build(BuildContext context) {
    final videos = List.generate(20, (index) => "assets/images/video_placeholder.jpg");

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              // 🏷 Title (Outside AppBar)
              const Center(
                child: Text(
                  "Today's Videos",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🎬 Grid Gallery
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // more columns for 5+ rows
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 0.75, // controls height ratio
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return _videoCard(videos[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Individual video card
  Widget _videoCard(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          // 👇 Softer and lighter shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.25),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}