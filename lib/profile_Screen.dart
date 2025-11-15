// ... previous imports remain same
import 'package:codeera_digital_apk/LoginScreen.dart';
import 'package:codeera_digital_apk/Subscription_Screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'constant.dart';
import 'HomeScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String email = "";
  String name = "";
  String phone = "";
  String daysLeft = "";
  String startDate = "";
  String endDate = "";

  Future<void> getprofile() async {
    print('startprofile');
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
      print(data);

      if (response.statusCode == 200) {
        setState(() {
          name = data['name'] ?? "Rohit";
          daysLeft = data['total_days_left'].toString();
          email = data['email'].toString();
          phone= data['phone'].toString();

          // ✅ Parse and format dates to dd/MM/yyyy
          try {
            DateTime start = DateTime.parse(data['service_start_date']);
            DateTime end = DateTime.parse(data['service_end_date']);
            startDate = DateFormat('dd/MM/yyyy').format(start);
            endDate = DateFormat('dd/MM/yyyy').format(end);
          } catch (e) {
            print("Date format error: $e");
            startDate = "-";
            endDate = "-";
          }
        });
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


  @override
  void initState() {
    super.initState();
    getprofile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.4,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
            // 🔹 Profile Header
            Container(
              height: 130,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Colors.blue, size: 40),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Email:  $email",maxLines: 2,
                        style: const TextStyle(
                             color: Colors.black54),
                      ),
                      Text(
                        "Phone:  $phone",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            // 🔹 Subscription Gradient Card
            InkWell(onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Subscription_Screen()));
            },
              child: Container(
                height: 190,
                width: 330,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  image: DecorationImage(
                    image: const AssetImage("assets/premiumbg.jpg"), // 🔹 your image path here
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.25), // 🔹 adjust opacity here
                      BlendMode.darken, // you can use .overlay, .softLight, etc.
                    ),
                  ),

                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Package: Premium Plan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$daysLeft Days Left",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                        const Icon(Icons.workspace_premium, color: Colors.white, size: 22),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 🔹 Info Rows (Start Date, End Date, Payment)
                    _infoRow("Start Date", startDate),
                    const SizedBox(height: 6),
                    _infoRow("End Date", endDate),
                    const SizedBox(height: 6),
                    _infoRow("Payment Status", "Completed"),

                    const SizedBox(height: 5),

                    // 🔹 Renew Button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Renew button clicked!")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade700,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        ),
                        child: const Text(
                          "Renew",
                          style: TextStyle( color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ),

            const SizedBox(height: 5),

            // 🔹 Account Section
            _buildSectionTitle("Account",),
            _buildListTile(Icons.edit, "Edit Profile", () {}),
            _buildListTile(Icons.lock, "Change Password", () {}),
            _buildListTile(Icons.notifications_active, "Notifications", () {}),
            _buildListTile(Icons.privacy_tip, "Privacy & Security", () {}),


            const SizedBox(height: 10),

            // 🔹 App Settings
            _buildSectionTitle("App Settings"),
            _buildListTile(Icons.help_center, "Help & Support", () {}),
            _buildListTile(Icons.description, "Terms & Conditions", () {}),
            _buildListTile(Icons.logout, "Logout", () {
              _showLogoutDialog(context);
            }),
          ],
        ),
      ),
    );
  }

  // Reusable methods
  static Widget _dateColumn(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(date,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13.5)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 18, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18.5,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Logout",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              SharedPreferences preference = await SharedPreferences.getInstance();
              await preference.clear();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginWithOtpScreen()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Logged out successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text("Logout",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

Widget _infoRow(String title, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
