import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constant.dart';

class Subscription_Screen extends StatefulWidget {
  const Subscription_Screen({super.key});

  @override
  State<Subscription_Screen> createState() => _Subscription_ScreenState();
}

class _Subscription_ScreenState extends State<Subscription_Screen> {
  bool isLoading = true;
  bool hasError = false;

  Map<String, dynamic>? currentPlan;
  List<Map<String, dynamic>> plans = [];

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  /// 🔹 Load both Profile & Plans API
  Future<void> _loadSubscriptionData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      await getProfile();
      await getPlans();
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint("Error loading subscription data: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  /// 🔹 Get Profile (current plan details)
  Future<void> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final response = await http.get(
      Uri.parse("${baseurl.url}/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("🔹 PROFILE DATA: $data");

      setState(() {
        currentPlan = {
          "plan_name": data["plan_name"] ?? "N/A",
        };
      });
    } else {
      throw Exception("Failed to load profile data");
    }
  }

  /// 🔹 Get all available plans
  Future<void> getPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final response = await http.get(
      Uri.parse("https://codeeratech.in/api/plans"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("🔹 PLANS DATA: $data");
      final List<Map<String, dynamic>> allPlans =
      List<Map<String, dynamic>>.from(data['plans']);

      setState(() {
        plans = allPlans;
      });
    } else {
      throw Exception("Failed to load plans");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "My Subscription",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : hasError
          ? Center(
        child: Text(
          "❌ Failed to load data.\nPlease check your internet or login again.",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 15,
              fontWeight: FontWeight.w500),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            const Text(
              "Available Plans",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 15),

            /// 🔹 Horizontal scroll plans
            Container(height: 500,
              child: Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final bool isActive =
                    (currentPlan?["plan_name"] == plan["name"]);

                    // 🎨 Different gradient color for each plan
                    final gradients = [
                      [const Color(0xFF6D5DF6), const Color(0xFF8369F4)],
                      [const Color(0xFF00BFA5), const Color(0xFF1DE9B6)],
                      [const Color(0xFFFFB74D), const Color(0xFFFF9800)],
                      [const Color(0xFF42A5F5), const Color(0xFF478DE0)],
                      [const Color(0xFFE91E63), const Color(0xFFFF4081)],
                    ];

                    final colors = gradients[index % gradients.length];

                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 16),
                      child: _planCard(plan, isActive, colors),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Plan Card (Horizontal)
  /// 🔹 Plan Card (Horizontal)
  /// 🔹 Plan Card (Horizontal)
  Widget _planCard(
      Map<String, dynamic> plan, bool isActive, List<Color> colors) {
    // ✅ Handle both String or List<dynamic> for features/content
    List<String> features = [];

    if (plan['features'] != null) {
      if (plan['features'] is List) {
        features = List<String>.from(plan['features']);
      } else if (plan['features'] is String) {
        features = plan['features']
            .toString()
            .split(RegExp(r'[,\n]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } else if (plan['content'] != null) {
      if (plan['content'] is List) {
        features = List<String>.from(plan['content']);
      } else if (plan['content'] is String) {
        features = plan['content']
            .toString()
            .split(RegExp(r'[,\n]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } else {
      features = ["No features available for this plan."];
    }

    // ✅ Handle description safely
    final String description = plan['description']?.toString().trim().isNotEmpty == true
        ? plan['description'].toString().trim()
        : "No description available for this plan.";

    return Container(
      width: 300,
      constraints: const BoxConstraints(minHeight: 340, maxHeight: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Header Row
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.white, size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan['name'] ?? "Plan",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text(
                    "ACTIVE",
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            "₹${plan['price'] ?? 'N/A'}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          if (plan['duration'] != null)
            Text(
              plan['duration'].toString(),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),

          /// 🔹 Description (fully visible)
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),

          const Divider(color: Colors.white70, height: 16),

          /// 🔹 Features List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: features.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "• ${features[index]}",
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),
          if (!isActive)
            Center(
              child: Container(height: 40,width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Upgrade to ${plan['name']} clicked!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colors.first,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: const Text(
                    "Upgrade",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


}
