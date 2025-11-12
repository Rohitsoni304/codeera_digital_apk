import 'package:bubble_navigation_bar/bubble_navigation_bar.dart';
import 'package:codeera_digital_apk/Agoranewchats.dart';
import 'package:codeera_digital_apk/Chat_screen.dart';

import 'package:codeera_digital_apk/profile_Screen.dart';
import 'package:flutter/material.dart';

// Import your actual screens here 👇
import 'package:codeera_digital_apk/HomeScreen.dart';
import 'package:codeera_digital_apk/Overview_screen.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  final PageController _pageController = PageController();
  int _index = 0;

  // 🟢 Screens list
  final List<Widget> screens = [
    const HomeScreen(),
    const OverviewScreen(),
    const AgoraChatScreen(),
    const ProfileScreen(),

  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ PageView lets you swipe between pages or jump via nav bar
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _index = index);
        },
        children: screens,
      ),

      // ✅ Bubble Bottom Navigation
      bottomNavigationBar: BubbleNavigationBar(

        currentIndex: _index,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        onIndexChanged: (index) {
          setState(() => _index = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 240),
            curve: Curves.decelerate,
          );
        },
        items: const [
          BubbleNavItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BubbleNavItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BubbleNavItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BubbleNavItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
