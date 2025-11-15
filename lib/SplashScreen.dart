import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'BottomBar.dart';
import 'LoginScreen.dart';

import 'package:animated_text_kit/animated_text_kit.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 🎬 Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // ▶️ Start animation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });

    // ⏰ Now check login when splash is running
    Timer(const Duration(seconds: 4), _checkLoginStatus);
  }

  /// 🔥 LOGIN CHECK HERE
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("authToken");

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // 🔥 Already logged in → Go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Bottombar()),
      );
    } else {
      // ❌ Not logged in → Open Login Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginWithOtpScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 240, 240, 1.0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: child,
                  ),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: size.height * 0.75,
                      width: size.width * 0.75,
                      child: Image.asset("assets/images/codeera-logo.png"),
                    ),
                  ],
                ),

                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'INNOVATE | AUTOMATE | SUCCEED',
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      speed: Duration(milliseconds: 90),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
