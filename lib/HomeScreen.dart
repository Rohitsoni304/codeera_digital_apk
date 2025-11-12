import 'package:codeera_digital_apk/File_uploadScreen.dart';
import 'package:codeera_digital_apk/Notification_Services.dart';
import 'package:codeera_digital_apk/Overview_screen.dart';
import 'package:codeera_digital_apk/posters.dart';
import 'package:codeera_digital_apk/videosgallery.dart';
import 'package:flutter/material.dart';
import 'package:codeera_digital_apk/Todaysvideo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'BottomBar.dart';
import 'constant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Keeping your variables as-is
String name = "";
String daysLeft = "";
String TaskStatus = "";
String videos = '';
String posts = '';
String totalvideos = '';

class _HomeScreenState extends State<HomeScreen> {
  Future<void> getdata() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    try {
      final response = await http.get(
        Uri.parse("${baseurl.url}/user/video-count"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          videos = data['counts']['video'].toString();
          posts = data['counts']['post'].toString();
        });
      }
    } catch (e) {
      debugPrint("Network error: $e");
    }
  }

  Future<void> getprofile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    try {
      final response = await http.get(
        Uri.parse("${baseurl.url}/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          name = data['name'] ?? "User";
          daysLeft = data['total_days_left']?.toString() ?? "0";
        });
      }
    } catch (e) {
      debugPrint("Profile error: $e");
    }
  }

  Future<void> getprogress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    try {
      final response = await http.get(
        Uri.parse("${baseurl.url}/config/constant"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          TaskStatus = data["TASK_STATUS"] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Progress error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getprofile();
    getdata();
    getprogress();
    NotificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final padding = width * 0.04;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 👋 Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Hello ${name.isNotEmpty ? name : 'User'}",
                      style: TextStyle(
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${daysLeft.isNotEmpty ? daysLeft : '0'} Days Left",
                      style: TextStyle(
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.015),

              /// 🔹 Summary Section
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Here's your marketing performance summary.",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: width * 0.035,
                      ),
                    ),
                  ),
                  Icon(Icons.notifications, size: width * 0.075, color: Colors.black),
                ],
              ),

              SizedBox(height: height * 0.02),

              /// 📊 Stats Cards (responsive row)
              SingleChildScrollView(
                // scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    StatsCard(
                      icon: Icons.videocam,
                      value: videos.isNotEmpty ? videos : "0",
                      label: " Total\nVideos",
                      percent: "+14%",
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => TodayVideosGalleryScreen())),
                    ),
                    StatsCard(
                      icon: Icons.image,
                      value: posts.isNotEmpty ? posts : "0",
                      label: "  Total\nPosters",
                      percent: "+20%",
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => posterGalleryScreen())),
                    ),
                    const StatsCard(
                      icon: Icons.insert_drive_file,
                      value: "13M",
                      label: " Followers\n  Gained",
                      percent: "+18%",
                    ),
                    const StatsCard(
                      icon: Icons.star,
                      value: "20",
                      label: "  GMB\nReviews",
                      percent: "+25%",
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),

              /// 📆 Today's Progress
              Text(
                "Today's Progress",
                style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.015),

              Column(
                children: const [
                  ProgressTile(
                    icon: FontAwesomeIcons.instagram,
                    color: Colors.purpleAccent,
                    title: "Instagram",
                    status: "Reel posted",
                    done: true,
                  ),
                  ProgressTile(
                    icon: FontAwesomeIcons.facebook,
                    color: Colors.blue,
                    title: "Facebook",
                    status: "1 Image post",
                    done: true,
                  ),
                  ProgressTile(
                    icon: FontAwesomeIcons.linkedin,
                    color: Colors.blueAccent,
                    title: "LinkedIn",
                    status: "Caption under review",
                    done: false,
                  ),
                  ProgressTile(
                    icon: FontAwesomeIcons.google,
                    color: Colors.orange,
                    title: "GMB",
                    status: "Pending upload",
                    done: false,
                  ),
                ],
              ),

              SizedBox(height: height * 0.03),

              /// 📅 Weekly Overview
              Text(
                "This Week's Marketing Overview",
                style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.015),

              Container(
                height: height * 0.25,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: BarChart(
                  BarChartData(
                    maxY: 5,
                    minY: 0,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, _) => Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: width * 0.03, color: Colors.black54),
                          ),
                        ),
                      ),
                      rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, _) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[value.toInt() % days.length],
                                style: TextStyle(
                                  fontSize: width * 0.03,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      _bar(0, 3),
                      _bar(1, 2),
                      _bar(2, 4),
                      _bar(3, 3),
                      _bar(4, 2.5),
                      _bar(5, 2.2),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),

              /// 🆕 Recent Uploads
              Text(
                "Recent Uploads",
                style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.015),

              SizedBox(
                height: height * 0.15,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:  [
                    InkWell(onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>TodayVideosScreen()));
                    },
                        child: UploadCard(title: "Today's\nVideos", color: Colors.redAccent)),
                    UploadCard(title: "Today's\nPosters", color: Colors.amberAccent),
                    UploadCard(title: "Posters", color: Colors.brown),
                    UploadCard(title: "Videos", color: Colors.amber),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 18,
          borderRadius: BorderRadius.circular(6),
          color: Colors.blueAccent,
        ),
      ],
    );
  }
}

/// Widgets below unchanged — just responsive in sizing

class StatsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String percent;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.percent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: width * 0.33,
        width: width * 0.196,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 0)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blueAccent, size: width * 0.05),
            SizedBox(height: width * 0.015),
            Text(value,
                style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w700)),
            Text(percent,
                style: TextStyle(color: Colors.green, fontSize: width * 0.03)),
          ],
        ),
      ),
    );
  }
}

class ProgressTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String status;
  final bool done;

  const ProgressTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.status,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: width * 0.06),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: width * 0.035, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: width * 0.03,
              color: done ? Colors.green : Colors.black54,
              fontWeight: done ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            done ? Icons.check_circle : Icons.timelapse_rounded,
            color: done ? Colors.green : Colors.orangeAccent,
            size: width * 0.04,
          ),
        ],
      ),
    );
  }
}

class UploadCard extends StatelessWidget {
  final String title;
  final Color color;

  const UploadCard({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.35,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
