import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _isDownloading = false;

  /// 👇 Default displayed date
  DateTime _selectedDate = DateTime.now();

  /// 🟢 Function to show month-year picker
  Future<void> _selectMonth(BuildContext context) async {
    final DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year - 5);
    DateTime lastDate = DateTime(now.year + 5);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: "Select Month",
      fieldHintText: "MM/YYYY",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String get formattedMonthYear {
    return "${_monthName(_selectedDate.month)} ${_selectedDate.year}";
  }

  String _monthName(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Marketing Overview",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Date Section (Clickable)
            GestureDetector(
              onTap: () => _selectMonth(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    formattedMonthYear,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.calendar_today,
                      color: Colors.blueAccent, size: 18),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 Stats cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                OverviewStatCard(
                    icon: Icons.videocam, value: "8", label: "Total Videos"),
                OverviewStatCard(
                    icon: Icons.image, value: "24", label: "Total Posters"),
                OverviewStatCard(
                    icon: Icons.person, value: "78", label: "Total Posts"),
                OverviewStatCard(
                    icon: Icons.star, value: "14", label: "GMB Reviews"),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Daily Activity Summary",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              height: size.height * 0.22,
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
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, _) {
                          if (value % 1 == 0 && value >= 0 && value <= 5) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
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
                              style: const TextStyle(
                                fontSize: 12,
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
            ), // bar chart

            const SizedBox(height: 25),
            const Text(
              "Insights",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(
                  child: InsightCard(
                    icon: Icons.trending_up,
                    value: "+18%",
                    label: "Engagement Growth",
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: InsightCard(
                    icon: Icons.arrow_upward,
                    value: "+120",
                    label: "Followers Gained",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isDownloading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "View Full Report",
                  style:
                  TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
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
          width: 22,
          borderRadius: BorderRadius.circular(6),
          color: Colors.blueAccent,
        ),
      ],
    );
  }
}

// ------------------- Widgets -------------------

class OverviewStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const OverviewStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const InsightCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
